defmodule Cli.CmdsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Cli.Cmds

  test "error message is printed" do
    output = capture_io(fn -> Cli.Cmds.print_error("Mensagem de Erro Generica") end)
    assert output == "ERR \"Mensagem de Erro Generica\"\n"
  end
end
