defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)
    workers = Enum.into(0..2, %{}, &start_worker/1)
    {:ok, workers}
  end

  defp start_worker(n) do
    {:ok, worker} = Todo.DatabaseWorker.start(@db_folder)
    {n, worker}
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _from, workers) do
    {:reply, choose_worker(key, workers), workers}
  end

  defp choose_worker(key, workers) do
    Map.get(workers, :erlang.phash2(key, 3))
  end
end
