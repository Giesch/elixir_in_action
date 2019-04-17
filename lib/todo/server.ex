defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(name) do
    IO.puts("Starting todo server for #{name}")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(name) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:ok, {name, todo_list}}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    todo_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, todo_list)
    {:noreply, {name, todo_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, todo_list}) do
    reply = Todo.List.entries(todo_list, date)
    {:reply, reply, {name, todo_list}}
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
