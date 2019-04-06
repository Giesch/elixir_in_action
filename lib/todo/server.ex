defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(__MODULE__, name)
  end

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add_entry, entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(name) do
    {:ok, {name, Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    todo_list = Todo.List.add_entry(todo_list, entry)
    {:noreply, {name, todo_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {name, todo_list}) do
    reply = Todo.List.entries(todo_list, date)
    {:reply, reply, {name, todo_list}}
  end
end
