defmodule CliTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Cli

  # Uma string será representada pelo seu texto. 
  # Qualquer sequência de caracteres não contenha 
  # somente dígitos e que seja diferente de TRUE, FALSE ou NIL 
  # será interpretada como uma string. 
  # Caso a string contenha espaços em branco, contenha somente 
  # dígitos, seja TRUE, FALSE, ou NIL, ela deve ser cercada de aspas duplas.
  test "parse_command_and_args" do
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


    # Testing multi word command
    assert Cli.parse_command_and_args("'BEGIN COMMAND'") == {"BEGIN COMMAND", []}


    # Testing simple commands + lowercase
    assert Cli.parse_command_and_args("HELP") == {"HELP", []}
    assert Cli.parse_command_and_args("help") == {"HELP", []}

    assert Cli.parse_command_and_args("COMMIT") == {"COMMIT", []}
    assert Cli.parse_command_and_args("commit") == {"COMMIT", []}

    assert Cli.parse_command_and_args("ROLLBACK") == {"ROLLBACK", []}
    assert Cli.parse_command_and_args("rollback") == {"ROLLBACK", []}

    assert Cli.parse_command_and_args("EXIT") == {"EXIT", []}
    assert Cli.parse_command_and_args("exit") == {"EXIT", []}


    # Testing boolean parsing
    assert Cli.parse_command_and_args("SET 'TRUE' TRUE") == {"SET", ["TRUE", true]}
    assert Cli.parse_command_and_args("SET 'FALSE' FALSE") == {"SET", ["FALSE", false]}
    assert Cli.parse_command_and_args("SET FALSE TRUE") == {"SET", [false, true]}

    # Testing NIL parsing
    assert Cli.parse_command_and_args("SET NIL FALSE") == {"SET", [nil, false]}

    # Testing integer parsing
    assert Cli.parse_command_and_args("SET ola 10") == {"SET", ["ola", 10]}
    assert Cli.parse_command_and_args("SET ola 2000") == {"SET", ["ola", 2000]}

  end

  test "process_input_GET_syntax_error" do
    assert Cli.process_input("GET a b c d") == :syntax_error
    assert Cli.process_input("GET a b") == :syntax_error
    assert Cli.process_input("GET") == :syntax_error
  end

  test "process_input_SET_syntax_error" do
    assert Cli.process_input("SET a b c d") == :syntax_error
    assert Cli.process_input("SET 'argumento a'") == :syntax_error
    assert Cli.process_input("SET") == :syntax_error
  end

  test "process_input_BEGIN_syntax_error" do
    assert Cli.process_input("BEGIN a") == :syntax_error
    assert Cli.process_input("BEGIN a 'ola mundo'") == :syntax_error
  end

  test "process_input_ROLLBACK_syntax_error" do
    assert Cli.process_input("ROLLBACK a") == :syntax_error
    assert Cli.process_input("ROLLBACK a 'ola mundo'") == :syntax_error
  end

  test "process_input_COMMIT_syntax_error" do
    assert Cli.process_input("COMMIT a") == :syntax_error
    assert Cli.process_input("COMMIT a 'ola mundo'") == :syntax_error
  end
end
