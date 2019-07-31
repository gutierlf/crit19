defmodule Crit.Sql.PrefixServerTest do

  use Crit.DataCase
  alias Crit.Repo
  alias Crit.Sql
  alias Crit.Audit.ToEcto.Record  # It's one of the simplest table types.


  @institution "institution"
  @prefix "demo"

  setup do
    demo_prefix_server = start_supervised!({Sql.PrefixServer, @prefix})
    start_supervised!({Sql, %{@institution => demo_prefix_server}})
    []
  end
    

  test "use of the server" do

    assert {:ok, direct} = Repo.insert(something(), prefix: @prefix)
    assert {:ok, indirect} = Sql.insert(something(), Sql.server_for(@institution))

    assert_inserted_the_same(direct, indirect)
    assert_in_postgres_schema(indirect)
  end


  def something do 
    params = %{event: "event", event_owner_id: 3, data: %{"a" => 1}}
    Record.changeset(%Record{}, params)
  end

  def assert_inserted_the_same(one, other) do
    assert one.event == other.event
    assert one.event_owner_id == other.event_owner_id
    assert one.data == other.data
  end

  def assert_in_postgres_schema(inserted) do
    fetched = Repo.get(Record, inserted.id, prefix: @prefix)
    assert_inserted_the_same(inserted, fetched)
  end


end
