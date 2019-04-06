defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process/2" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "todo operations" do
    {:ok, cache} = Todo.Cache.start()
    alice = Todo.Cache.server_process(cache, "alice")
    Todo.Server.add_entry(alice, %{date: ~D[2018-12-19], title: "Dentist"})

    [entry | _rest] = Todo.Server.entries(alice, ~D[2018-12-19])
    expected_entry = %{date: ~D[2018-12-19], title: "Dentist"}

    assert entry = expected_entry
  end
end
