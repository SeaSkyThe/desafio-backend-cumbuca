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

  @doc """
  Função que define o comportamento do comando SET.

  Define o valor de uma chave, caso ela já exista, sobreescreve o valor.

  Parâmetros:
    - `args`: Lista de strings contendo os argumentos passados na linha de comando. 
            Onde o primeiro argumento é a chave e o segundo é o valor a ser associado com essa chave.
  Retorno: 
    - `{existe :: boolean, valor :: T}`: 
      - `existe`: Se a chave existe ou não.
        - `true`: Se a chave existe e foi sobreescrita.
        - `false`: Se a chave não existe.
      - `valor`: O valor associado com a chave. Onde `T` é o tipo do valor armazenado.
  """
  def set(args) do
    raise "Not implemented yet"
  end

  @doc """
  Função que define o comportamento do comando GET.

  Recupera o valor de uma chave. 
  Caso a chave não exista, retorna `NIL`.

  Parâmetros:
    - `args`: Lista de strings contendo os argumentos passados na linha de comando. 
            Onde o primeiro, e único, argumento é a chave cujo valor será recuperado.
  Retorno: 
    - `{valor :: T}`: 
      - `valor`: O valor associado com a chave. Onde `T` é o tipo do valor armazenado.
  """
  def get(args) do
    raise "Not implemented yet"
  end

  @doc """
  Função que define o comportamento do comando BEGIN.

  Inicia uma transação.

  Parâmetros:
    - Não recebe parâmetros.

  Retorno: 
    - `nivel_de_transacao :: integer`: 
      - `nivel_de_transacao`: O nível de transação atual (i.e. quantas transações abertas existem).
  """
  def begin() do
    raise "Not implemented yet"
  end

  @doc """
  Função que define o comportamento do comando ROLLBACK.

  Finaliza uma transação sem aplicar suas alterações.
  Isto é, todas as alterações feitas dentro da transação são descartadas.

  Parâmetros:
    - Não recebe parâmetros.

  Retorno: 
    - `nivel_de_transacao :: integer`: 
      - `nivel_de_transacao`: O nível de transação após o rollback.
  """
  def rollback() do
    raise "Not implemented yet"
  end

  @doc """
  Função que define o comportamento do comando COMMIT.

  Finaliza a transação atual aplicando todas as suas alterações.
  Isto é, todas as alterações feitas dentro da transação são aplicadas na transação superior.
  Caso após o commit não houver mais transações abertas, o resultado das transacoes, 
  deven ser efetivados no banco.

  Parâmetros:
    - Não recebe parâmetros.

  Retorno: 
    - `nivel_de_transacao :: integer`: 
      - `nivel_de_transacao`: O nível de transação após o commit.
  """
  def commit() do
    raise "Not implemented yet"
  end

  @doc """
  Função que imprime uma mensagem de erro.
  """
  def print_error(err) do
    IO.puts("ERR \"#{err}\"")
  end
end
