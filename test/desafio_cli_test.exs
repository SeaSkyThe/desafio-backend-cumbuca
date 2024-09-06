defmodule DesafioCliTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  doctest DesafioCli

  def loop(db, inputs) do
    input =
      case inputs do
        [h | t] ->
          h
          new_db = Cli.process_input(h, db)
          loop(new_db, t)

        [] ->
          db
      end
  end

  # Exemplo dado no desafio
  test "CLI Loop - Case 1" do
    commands = [
      # NIL
      "GET teste",
      # 1
      "BEGIN",
      # FALSE 1
      "SET teste 1",
      # 1
      "GET teste",
      # 2
      "BEGIN",
      # FALSE bar
      "SET foo bar",
      # FALSE baz
      "SET bar baz",
      # bar
      "GET foo",
      # baz
      "GET bar",
      # 1
      "COMMIT",
      # bar
      "GET foo",
      # baz
      "GET bar",
      # 1
      "GET teste",
      # 0
      "ROLLBACK",
      # NIL
      "GET teste",
      # NIL
      "GET foo",
      # NIL
      "GET bar"
    ]

    original_db = Kvdb.new()

    expected_outputs = [
      "NIL",
      "1",
      "FALSE 1",
      "1",
      "2",
      "FALSE bar",
      "FALSE baz",
      "bar",
      "baz",
      "1",
      "bar",
      "baz",
      "1",
      "0",
      "NIL",
      "NIL",
      "NIL"
    ]

    expected_db = %Kvdb{
      transactions: [
        %{}
      ]
    }

    # output = ""NIL\n1\nFALSE 1\n1\n2\nFALSE bar\nFALSE baz\nbar\nbaz\n1\nbar\nbaz\n1\n0\nNIL\nNIL\nNIL\n"
    output = capture_io(fn -> loop(original_db, commands) end)
    # remove o ultimo, pois será um ""
    output_list = String.split(output, "\n") |> List.delete_at(-1)

    assert output_list == expected_outputs

    output_db = loop(original_db, commands)
    assert output_db == expected_db
  end

  test "CLI Loop - Case 2" do
    commands = [
      "SET 'minha variavel' '\"Valor\" da variavel'",
      "SET a false",
      "SET b true",
      "BEGIN",
      "SET a 'O valor de \"a\" mudou no nivel 1'",
      "SET b 123",
      "COMMIT"
    ]

    original_db = Kvdb.new()

    expected_outputs = [
      "FALSE \"Valor\" da variavel",
      "FALSE false",
      "FALSE true",
      "1",
      "FALSE O valor de \"a\" mudou no nivel 1",
      "FALSE 123",
      "0"
    ]

    expected_db = %Kvdb{
      transactions: [
        %{
          "minha variavel" => "\"Valor\" da variavel", 
          "a" => "O valor de \"a\" mudou no nivel 1",
          "b" => 123,
        }
      ]
    }

    output = capture_io(fn -> loop(original_db, commands) end)
    output_list = String.split(output, "\n") |> List.delete_at(-1)

    assert output_list == expected_outputs

    output_db = loop(original_db, commands)
    assert output_db == expected_db
  end
end
