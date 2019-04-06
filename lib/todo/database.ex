defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)

    workers = %{
      0 => start_worker(),
      1 => start_worker(),
      2 => start_worker()
    }

    {:ok, workers}
  end

  defp start_worker() do
    {:ok, worker} = Todo.DatabaseWorker.start(@db_folder)
    worker
  end

  @impl GenServer
  def handle_cast({:store, key, data}, workers) do
    key
    |> choose_worker(workers)
    |> Todo.DatabaseWorker.store(key, data)

    {:noreply, workers}
  end

  @impl GenServer
  def handle_call({:get, key}, caller, workers) do
    reply =
      key
      |> choose_worker(workers)
      |> Todo.DatabaseWorker.get(key, caller)

    {:reply, reply, workers}
  end

  defp choose_worker(key, workers) do
    Map.get(workers, :erlang.phash2(key, 3))
  end
end
