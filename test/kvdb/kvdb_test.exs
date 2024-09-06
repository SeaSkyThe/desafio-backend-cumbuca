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

  test "BEGIN command", %{db: db} do
    assert Kvdb.transaction_level(db) == 0

    {transaction_level, new_db} = Kvdb.begin(db)
    assert transaction_level == 1
    assert length(new_db.transactions) == 2

    {transaction_level, new_db2} = Kvdb.begin(new_db)
    assert transaction_level == 2
    assert length(new_db2.transactions) == 3

    {transaction_level, new_db3} = Kvdb.begin(new_db2)
    assert transaction_level == 3
    assert length(new_db3.transactions) == 4

    {transaction_level, new_db4} = Kvdb.begin(new_db3)
    assert transaction_level == 4
    assert length(new_db4.transactions) == 5
  end

  test "ROLLBACK command", %{db: db} do
    assert Kvdb.transaction_level(db) == 0

    {_, db1} = Kvdb.begin(db)
    {_, db2} = Kvdb.begin(db)
    {_, db3} = Kvdb.begin(db2)
    {t4, db4} = Kvdb.begin(db3)
    assert t4 == 3

    {transaction_level, new_db} = Kvdb.rollback(db4)
    assert transaction_level == 2

    {transaction_level2, new_db2} = Kvdb.rollback(new_db)
    assert transaction_level2 == 1

    {transaction_level3, new_db3} = Kvdb.rollback(new_db2)
    assert transaction_level3 == 0

    # Keep the db state and transaction_level at 0
    {transaction_level4, new_db4} = Kvdb.rollback(new_db3)
    assert transaction_level4 == 0
    assert new_db4 == new_db3
  end

  test "COMMIT command" do
    expected_db = %Kvdb{transactions: [%{"a" => 1, "b" => 2, "c" => 3, "d" => 4}]}
    expected_transaction_level = 0

    db = %Kvdb{
      transactions: [
        %{"a" => 1, "b" => 2},
        %{"b" => "dois", "c" => 3},
        %{"c" => true},
        %{"d" => 4}
      ]
    }

    {transaction_level1, new_db} = Kvdb.commit(db)
    {transaction_level2, new_db2} = Kvdb.commit(new_db)
    {transaction_level3, new_db3} = Kvdb.commit(new_db2)

    assert transaction_level3 == expected_transaction_level
    assert new_db3 == expected_db
  end
end
