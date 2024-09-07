defmodule Cli.Cmds do
  @moduledoc """
  Módulo responsável por definir os comandos disponíveis na CLI e tratá-los.
  """

  def help() do
    IO.puts("Comandos disponíveis:")
    IO.puts("  HELP - Mostra este menu")
    IO.puts("  EXIT - Sai do programa")
    IO.puts("  SET <chave> <valor> - Define o valor de uma chave na transação atual")
    IO.puts("  GET <chave> - Recupera o valor de uma chave na transação atual")
    IO.puts("  BEGIN - Inicia uma transação")
    IO.puts("  ROLLBACK - Cancela a transação atual")
    IO.puts("  COMMIT - Aplica as alterações da transação atual")
  end

  def set(db, [key, value]) when is_binary(key) do
    case value do
      nil ->
        print_error("SET <chave> <valor> -> <valor> can't be NIL")
        db

      _ ->
        {exists, value, new_db} = Kvdb.set(db, key, value)
        IO.write("#{if exists, do: "TRUE", else: "FALSE"} ")
        print_return_value(value)
        new_db
    end
  end

  def set(_db, _) do
    print_error("SET <chave> <valor> - Syntax error")
    :syntax_error
  end

  def get(db, [key]) when is_binary(key) do
    {value, new_db} = Kvdb.get(db, key)
    print_return_value(value)
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
    case Kvdb.transaction_level(db) do
      0 ->
        print_error("You can't ROLLBACK at transaction level 0: No transactions to revert.")
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
    case Kvdb.transaction_level(db) do
      0 ->
        print_error(
          "You can't COMMIT at transaction level 0: Your changes were already applied to the database."
        )

        :syntax_error

      _ ->
        {transaction_level, new_db} = Kvdb.commit(db)
        IO.puts("#{transaction_level}")
        new_db
    end
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

  defp print_return_value(value) do
    case value do
      nil ->
        IO.puts("NIL")

      true ->
        IO.puts("TRUE")

      false ->
        IO.puts("FALSE")

      "TRUE" ->
        IO.puts("'TRUE'")

      "FALSE" ->
        IO.puts("'FALSE'")

      "NIL" ->
        IO.puts("'NIL'")

      _ when is_binary(value) ->
        case Integer.parse(value, 10) do
          {int_value, ""} ->
            IO.puts("'#{int_value}'")

          _ ->
            if String.contains?(value, " ") do
              IO.puts("'#{value}'")
            else
              IO.puts(value)
            end
        end

      _ ->
        IO.puts(value)
    end
  end
end
