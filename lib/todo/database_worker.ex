defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    IO.puts("Starting database worker #{worker_id}")
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  @impl GenServer
  def init(folder) do
    {:ok, folder}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, folder) do
    key
    |> file_name(folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _, folder) do
    {:reply, lookup(key, folder), folder}
  end

  defp lookup(key, folder) do
    case File.read(file_name(key, folder)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
  end

  defp file_name(key, folder) do
    Path.join(folder, to_string(key))
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
