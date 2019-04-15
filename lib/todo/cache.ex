defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    IO.puts("Starting todo cache")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  @impl GenServer
  def init(_) do
    Todo.Database.start_link(nil)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, name}, _from, cache) do
    case Map.fetch(cache, name) do
      {:ok, server} ->
        put_and_reply(cache, name, server)

      :error ->
        {:ok, server} = Todo.Server.start_link(name)
        put_and_reply(cache, name, server)
    end
  end

  defp put_and_reply(cache, name, server) do
    {:reply, server, Map.put(cache, name, server)}
  end
end
