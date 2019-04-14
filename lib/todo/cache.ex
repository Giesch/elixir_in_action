defmodule Todo.Cache do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, name) do
    GenServer.call(cache_pid, {:server_process, name})
  end

  @impl GenServer
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, name}, _from, cache) do
    case Map.fetch(cache, name) do
      {:ok, todo_server} ->
        put_and_reply(cache, name, todo_server)

      :error ->
        {:ok, new_server} = Todo.Server.start(name)
        put_and_reply(cache, name, new_server)
    end
  end

  defp put_and_reply(cache, name, server) do
    {:reply, server, Map.put(cache, name, server)}
  end
end
