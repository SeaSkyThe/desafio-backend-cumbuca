defmodule Cli do
  @moduledoc """
  Módulo responsável por processar os argumentos passados na CLI.
  """

  @doc """
  A função main recebe os argumentos passados na linha de
  comando como lista de strings e executa a CLI.
  """

  def start() do
    db = Kvdb.new()
    IO.puts("\nWelcome to Cumbuca KEY-VALUE Store!\n")
    IO.puts("Type 'help' to see the list of available commands.")
    loop(db)
  end

  def loop(db) do
    input =
      IO.gets("Cumbuca-CLI > ")
      |> String.trim()

    if input != "" do
      new_db = process_input(input, db)
      loop(new_db)
    else
      loop(db)
    end
  end

  def process_input(input, db) do
    {cmd, args} = parse_command_and_args(input)

    case cmd do
      "HELP" ->
        Cli.Cmds.help()
        db

      "SET" ->
        handle_command_result(Cli.Cmds.set(db, args), db)

      "GET" ->
        handle_command_result(Cli.Cmds.get(db, args), db)

      "BEGIN" ->
        handle_command_result(Cli.Cmds.begin(db, args), db)

      "ROLLBACK" ->
        handle_command_result(Cli.Cmds.rollback(db, args), db)

      "COMMIT" ->
        handle_command_result(Cli.Cmds.commit(db, args), db)

      "EXIT" ->
        # Maybe we should save the db state here? 
        System.halt(0)

      _ ->
        IO.puts("ERR \"No command \'#{cmd}\'\"")
        db
    end
  end

  # Minha escolha foi utilizar aspas simples para representar strings
  def parse_command_and_args(input) do
    trimmed_input = String.trim(input)
    args_list = parse_args(trimmed_input, [], "", false, false)

    [cmd | args] = args_list

    cmd = String.trim(cmd, "'") |> String.upcase()

    parsed_args =
      Enum.map(
        args,
        fn arg ->
          case String.upcase(arg) do
            "TRUE" ->
              true

            "FALSE" ->
              false

            "NIL" ->
              nil

            _ ->
              case Integer.parse(arg) do
                {int_value, _} -> int_value
                _ -> String.trim(arg, "'")
              end
          end
        end
      )

    {cmd, parsed_args}
  end

  defp parse_args("", args, current_arg, _inside_quote, _escape) do
    if current_arg != "" do
      Enum.reverse([current_arg | args])
    else
      args
    end
  end

  defp parse_args(<<char::utf8, rest::binary>>, args, current_arg, inside_quote, escape) do
    case {char, inside_quote, escape} do
      # Handle escaped sequences
      {?\\, _, _} ->
        parse_args(rest, args, current_arg <> <<char::utf8>>, inside_quote, true)

      # Handle non escaped sequences
      # Handle start of quote
      {?', false, false} ->
        parse_args(rest, args, "'", true, false)

      # Handle end of quote
      {?', true, false} ->
        parse_args(rest, args, current_arg <> "'", false, false)

      # Handle whitespace (end of argument)
      {chr, false, false} when chr in [?\s, ?\t, ?\n] ->
        parse_args(rest, [current_arg | args], "", inside_quote, false)

      _ ->
        parse_args(rest, args, current_arg <> <<char::utf8>>, inside_quote, false)
    end
  end

  defp handle_command_result(:syntax_error, db), do: db
  defp handle_command_result(new_db, _db), do: new_db
end
