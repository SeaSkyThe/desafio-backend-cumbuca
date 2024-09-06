defmodule Cli.Cmds do
  @moduledoc """
  Módulo responsável por definir os comandos disponíveis na CLI e tratá-los.
  """

  @doc """
  Função que imprime a mensagem de ajuda.
  """
  def help() do
    IO.puts("Comandos disponíveis:")
    IO.puts("  HELP - Mostra este menu")
    IO.puts("  EXIT - Sai do programa")
    IO.puts("  SET <chave> <valor> - Define o valor de uma chave")
    IO.puts("  GET <chave> - Recupera o valor de uma chave")
    IO.puts("  BEGIN - Inicia uma transação")
    IO.puts("  ROLLBACK - Cancela a transação atual")
    IO.puts("  COMMIT - Aplica as alterações da transação atual")
  end

  def set(db, [key, value]) when is_binary(key) do
    {exists, value, new_db} = Kvdb.set(db, key, value)
    IO.puts("#{if exists, do: "TRUE", else: "FALSE"} #{value}")
    new_db
  end

  def set(_db, _) do
    print_error("SET <chave> <valor> - Syntax error")

    :syntax_error
  end

  def get(db, [key]) when is_binary(key) do
    {value, new_db} = Kvdb.get(db, key)
    IO.puts("#{if value == nil, do: "NIL", else: value}")
    new_db
  end

  def get(_db, _) do
    print_error("GET <chave> - Syntax error")
    :syntax_error
  end

  def begin(db, []) do
    {transaction_level, new_db} = Kvdb.begin(db)
    IO.puts("#{transaction_level}")
    new_db
  end

  def begin(_db, _) do
    print_error("BEGIN does not accept arguments - Syntax error")
    :syntax_error
  end

  def rollback(db, []) do
    # Should this check be internal to Kvdb module?
    case Kvdb.transaction_level(db) do
      0 ->
        print_error("You can't ROLLBACK at level 0: No transactions to revert.")
        :syntax_error

      _ ->
        {transaction_level, new_db} = Kvdb.rollback(db)
        IO.puts("#{transaction_level}")
        new_db
    end
  end

  def rollback(_db, _) do
    print_error("ROLLBACK does not accept arguments - Syntax error")
    :syntax_error
  end

  def commit(db, []) do
    raise "Not implemented yet"
  end

  def commit(_db, _) do
    print_error("COMMIT does not accept arguments - Syntax error")
    :syntax_error
  end

  @doc """
  Função que imprime uma mensagem de erro.
  """
  def print_error(err) do
    IO.puts("ERR \"#{err}\"")
  end
end
