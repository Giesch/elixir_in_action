defmodule Todo.List do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, &add_entry(&2, &1))
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)
    %Todo.List{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.map(fn {_, entry} -> entry end)
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, entry_id, update_fn) do
    case Map.fetch(todo_list.entries, entry_id) do
      {:ok, old_entry} -> update_existing_entry(todo_list, old_entry, update_fn)
      :error -> todo_list
    end
  end

  defp update_existing_entry(todo_list, old_entry, update_fn) do
    new_entry = update_fn.(old_entry)
    new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
    %Todo.List{todo_list | entries: new_entries}
  end

  def delete_entry(todo_list, entry_id) do
    %Todo.List{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end
