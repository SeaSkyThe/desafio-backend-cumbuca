defmodule KvdbTest do
  use ExUnit.Case
  doctest Kvdb

  setup do
    db = Kvdb.new()
    {:ok, db: db}
  end

  test "SET command and DB State", %{db: db} do
    {exists, value, new_db} = Kvdb.set(db, "key", "value")
    assert exists == false
    assert value == "value"
    assert new_db == %Kvdb{transactions: [%{"key" => "value"}]}

    {exists, value, new_db} = Kvdb.set(new_db, "key", "new_value")
    assert exists == true
    assert value == "new_value"
    assert new_db == %Kvdb{transactions: [%{"key" => "new_value"}]}

    {exists, value, new_db} = Kvdb.set(new_db, "new_key", "new_value2")
    assert exists == false
    assert value == "new_value2"
    assert new_db == %Kvdb{transactions: [%{"key" => "new_value", "new_key" => "new_value2"}]}
  end

  test "GET command and DB State", %{db: db} do
    {value, new_db} = Kvdb.get(db, "key")
    assert value == nil
    assert new_db == db

    temp_db = %Kvdb{transactions: [%{"key" => "value"}]}
    {value, new_db} = Kvdb.get(temp_db, "key")
    assert value == "value"
    assert new_db == temp_db
  end
end
