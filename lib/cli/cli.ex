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

  def parse_command_and_args(input) do
    trimmed_input = String.trim(input)
    # Regex: Match qualquer grupo de carcateres entre aspas ('...')  (exceto aspas)
    # ou qualquer caractere que não seja um espaço em branco ('\s')
    # returns a list of lists (first element of each list holds the match, after that its the captured groups)
    args_list =
      Regex.scan(~r/'([^']+)'|[^\s]+/, trimmed_input)
      |> Enum.map(fn [match | _] -> match end)

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

  defp handle_command_result(:syntax_error, db), do: db
  defp handle_command_result(new_db, _db), do: new_db
end
