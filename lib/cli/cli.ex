defmodule Cli do
  @moduledoc """
  Módulo responsável por processar os argumentos passados na CLI.
  """

  @doc """
  A função main recebe os argumentos passados na linha de
  comando como lista de strings e executa a CLI.
  """

  def start() do
    IO.puts("\nWelcome to Cumbuca KEY-VALUE Store!\n")
    IO.puts("Type 'help' to see the list of available commands.")
    loop()
  end

  def loop() do
    input =
      IO.gets("Cumbuca-CLI > ")
      |> String.trim()

    if input != "" do
      process_input(input)
    end

    loop()
  end

  def process_input(input) do
    IO.puts("Processando Input: #{input}")

    {cmd, args} = parse_command_and_args(input)

    IO.puts("Comando: #{cmd}")
    IO.puts("Args: ")
    Enum.map(args, fn x -> IO.puts(x) end)

    case cmd do
      "HELP" ->
        Cli.Cmds.help()

      "SET" ->
        Cli.Cmds.set(args)

      "GET" ->
        Cli.Cmds.get(args)

      "BEGIN" ->
        Cli.Cmds.begin(args)

      "ROLLBACK" ->
        Cli.Cmds.rollback(args)

      "COMMIT" ->
        Cli.Cmds.commit(args)

      "EXIT" ->
        System.halt(0)

      _ ->
        IO.puts("ERR \"No command \'#{cmd}\'\"")
        :unknown_command
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

    parsed_args = Enum.map(
      args,
      fn arg ->
        case String.upcase(arg) do
          "TRUE" -> true
          "FALSE" -> false
          "NIL" -> nil
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
end
