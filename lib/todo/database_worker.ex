defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(folder) do
    IO.puts("Starting database worker")
    GenServer.start_link(__MODULE__, folder)
  end

  def store(worker, key, data) do
    GenServer.cast(worker, {:store, key, data})
  end

  def get(worker, key) do
    GenServer.call(worker, {:get, key})
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
end
