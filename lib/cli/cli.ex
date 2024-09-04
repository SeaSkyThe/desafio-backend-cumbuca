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
    IO.gets("Cumbuca-CLI > ")
    |> String.trim()
    |> process_input()

    loop()
  end

  def process_input(input) do
    IO.puts("Processando Input: #{input}")

    args = String.split(input, " ")
    cmd = String.upcase(List.first(args))

    case cmd do
      "HELP" -> Cli.Cmds.help()
      "SET" -> Cli.Cmds.set(args)
      "GET" -> Cli.Cmds.get(args)
      "BEGIN" -> Cli.Cmds.begin()
      "ROLLBACK" -> Cli.Cmds.rollback()
      "COMMIT" -> Cli.Cmds.commit()
      "EXIT" -> System.halt(0)
      _ -> IO.puts("ERR \"No command #{cmd}\"")
    end
  end
end
