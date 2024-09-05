defmodule CliTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Cli

  setup do
    db = Kvdb.new()
    {:ok, db: db}
  end

  # Uma string será representada pelo seu texto. 
  # Qualquer sequência de caracteres não contenha 
  # somente dígitos e que seja diferente de TRUE, FALSE ou NIL 
  # será interpretada como uma string. 
  # Caso a string contenha espaços em branco, contenha somente 
  # dígitos, seja TRUE, FALSE, ou NIL, ela deve ser cercada de aspas duplas.

  # Argument parsing
  test "Parse Commands and Args Miscellaneous" do
    assert Cli.parse_command_and_args("SET 'key1' 'value1'") == {"SET", ["key1", "value1"]}
    assert Cli.parse_command_and_args("SET key1 value1") == {"SET", ["key1", "value1"]}
    assert Cli.parse_command_and_args("SET key1 'value1'") == {"SET", ["key1", "value1"]}
    assert Cli.parse_command_and_args("SET 'key1' value1") == {"SET", ["key1", "value1"]}

    assert Cli.parse_command_and_args("SET 'my multiple word key' 'my multiple word value'") ==
             {"SET", ["my multiple word key", "my multiple word value"]}

    assert Cli.parse_command_and_args("SET 'my \"multiple\" word key' 'my multiple word value'") ==
             {"SET", ["my \"multiple\" word key", "my multiple word value"]}

    assert Cli.parse_command_and_args("GET abcd") == {"GET", ["abcd"]}
    assert Cli.parse_command_and_args("GET a10") == {"GET", ["a10"]}

    assert Cli.parse_command_and_args("GET 'uma string com espacos'") ==
             {"GET", ["uma string com espacos"]}

    assert Cli.parse_command_and_args("GET '\"teste\"'") == {"GET", ["\"teste\""]}
    assert Cli.parse_command_and_args("GET '101'") == {"GET", ["101"]}
    assert Cli.parse_command_and_args("GET 'TRUE'") == {"GET", ["TRUE"]}
  end

  test "Parsing Simple Commands and Lowercase" do
    assert Cli.parse_command_and_args("HELP") == {"HELP", []}
    assert Cli.parse_command_and_args("help") == {"HELP", []}

    assert Cli.parse_command_and_args("COMMIT") == {"COMMIT", []}
    assert Cli.parse_command_and_args("commit") == {"COMMIT", []}

    assert Cli.parse_command_and_args("ROLLBACK") == {"ROLLBACK", []}
    assert Cli.parse_command_and_args("rollback") == {"ROLLBACK", []}

    assert Cli.parse_command_and_args("EXIT") == {"EXIT", []}
    assert Cli.parse_command_and_args("exit") == {"EXIT", []}
  end

  test "Parse multi-word commands" do
    assert Cli.parse_command_and_args("'BEGIN COMMAND'") == {"BEGIN COMMAND", []}
    assert Cli.parse_command_and_args("'ROLLBACK COMMAND'") == {"ROLLBACK COMMAND", []}
    assert Cli.parse_command_and_args("'COMMIT COMMAND'") == {"COMMIT COMMAND", []}
  end

  test "Parse Commands and Args Booleans" do
    assert Cli.parse_command_and_args("SET 'TRUE' TRUE") == {"SET", ["TRUE", true]}
    assert Cli.parse_command_and_args("SET 'FALSE' FALSE") == {"SET", ["FALSE", false]}
    assert Cli.parse_command_and_args("SET 'TRUE' TRUE") == {"SET", ["TRUE", true]}
  end

  test "Parse Commands and Args NIL" do
    assert Cli.parse_command_and_args("SET 'NIL' NIL") == {"SET", ["NIL", nil]}
  end

  test "Parse Commands and Args Integers" do
    assert Cli.parse_command_and_args("SET '101' 101") == {"SET", ["101", 101]}
    assert Cli.parse_command_and_args("SET ola 10") == {"SET", ["ola", 10]}
    assert Cli.parse_command_and_args("SET ola 2000") == {"SET", ["ola", 2000]}
  end

  # Argument processing
  #
  # Syntax Errors
  test "Process Input - GET -> Syntax Error", %{db: db} do
    assert Cli.process_input("GET a b c d", db) == db
    assert Cli.process_input("GET a b", db) == db
    assert Cli.process_input("GET", db) == db
    assert Cli.process_input("GET 1", db) == db
  end

  test "Process Input - SET -> Syntax Error", %{db: db} do
    assert Cli.process_input("SET a b c d", db) == db
    assert Cli.process_input("SET 'argumento a'", db) == db
    assert Cli.process_input("SET", db) == db
  end

  test "Process Input - BEGIN -> Syntax Error", %{db: db} do
    assert Cli.process_input("BEGIN a", db) == db
    assert Cli.process_input("BEGIN a 'ola mundo'", db) == db
  end

  test "Process Input - ROLLBACK -> Syntax Error", %{db: db} do
    assert Cli.process_input("ROLLBACK a", db) == db
    assert Cli.process_input("ROLLBACK a 'ola mundo'", db) == db
  end

  test "Process Input - COMMIT -> Syntax Error", %{db: db} do
    assert Cli.process_input("COMMIT a", db) == db
    assert Cli.process_input("COMMIT a 'ola mundo'", db) == db
  end

  # Successful Processing
  test "Process Input - GET -> Success" do
    new_db = %Kvdb{transactions: [%{"a" => 3}]}
    assert Cli.process_input("GET a", new_db) == new_db
  end

  test "Process Input - SET -> Success", %{db: db} do
    new_db = %Kvdb{transactions: [%{"a" => 3}]}
    assert Cli.process_input("SET a 3", db) == new_db

    other_db = %Kvdb{transactions: [%{"ola mundo" => true}]}
    assert Cli.process_input("SET 'ola mundo' TRUE", db) == other_db
    assert Cli.process_input("SET 'ola mundo' true", db) == other_db

    yet_another_db = %Kvdb{transactions: [%{"TRUE" => 1415}]}
    assert Cli.process_input("SET 'TRUE' 1415", db) == yet_another_db

    here_we_go_again = %Kvdb{transactions: [%{"TRUE" => 1415, "FALSE" => false}]}
    assert Cli.process_input("SET 'FALSE' false", yet_another_db) == here_we_go_again


    well_well = %Kvdb{transactions: [%{"TRUE" => "changed", "FALSE" => false}]}
    assert Cli.process_input("SET 'TRUE' changed", here_we_go_again) == well_well

  end
end
