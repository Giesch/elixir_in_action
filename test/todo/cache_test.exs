defmodule Todo.CacheTest do
  use ExUnit.Case

  @tag :skip
  test "server_process/2" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  # TODO clean up persisted stuff before tests or use fixture
  @tag :skip
  test "todo operations" do
    {:ok, cache} = Todo.Cache.start()
    alice = Todo.Cache.server_process(cache, "alice")

    initial_entries_count = Enum.count(Todo.Server.entries(alice, ~D[2018-12-19]))
    Todo.Server.add_entry(alice, %{date: ~D[2018-12-19], title: "Dentist"})

    entries = Todo.Server.entries(alice, ~D[2018-12-19])
    entries_count = Enum.count(entries)

    assert entries_count == initial_entries_count + 1

    assert Enum.any?(entries, fn entry ->
             entry[:date] == ~D[2018-12-19] && entry[:title] == "Dentist"
           end)
  end
end
