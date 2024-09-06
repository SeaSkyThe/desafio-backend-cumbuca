defmodule Kvdb do
  @moduledoc """
  Módulo responsável por definir a estrutura principal do banco.
  Kvdb = Key-Value Database
  """

  defstruct transactions: []

  # Quanto mais à esquerda da lista, mais alto é o nível da transação
  def new() do
    %Kvdb{transactions: [%{}]}
  end

  def get_top_transaction(db) do
    [last | _] = db.transactions
    last
  end

  def transaction_level(db) do
    length(db.transactions) - 1
  end

  def update_top_transaction(db, new_transaction) do
    # Personal Reminder: the update syntax is confusing 
    # It would be the same as: %Kvdb{transactions: [new_transaction | old_transactions]} 
    case db.transactions do
      [_ | old_transactions] ->
        %{db | transactions: [new_transaction | old_transactions]}

      _ ->
        %{db | transactions: [new_transaction]}
    end
  end

  @doc """
  Função que define o comportamento do comando SET.

  Define o valor de uma chave, caso ela já exista, sobreescreve o valor.

  Parâmetros:
    - `args`: Lista de strings contendo os argumentos passados na linha de comando. 
            Onde o primeiro argumento é a chave e o segundo é o valor a ser associado com essa chave.
  Retorno: 
    - `{existe :: boolean, valor :: T, new_db :: Kvdb}`: 
      - `existe`: Se a chave existe ou não.
        - `true`: Se a chave existe e foi sobreescrita.
        - `false`: Se a chave não existe.
      - `valor`: O valor associado com a chave. Onde `T` é o tipo do valor armazenado.
      - `new_db`: Uma nova instancia do nosso banco de dados
  """
  def set(db, key, value) do
    curr_transaction = get_top_transaction(db)
    has_key = Map.has_key?(curr_transaction, key)

    updated_transaction = Map.put(curr_transaction, key, value)

    new_db = update_top_transaction(db, updated_transaction)

    {has_key, value, new_db}
  end

  @doc """
  Função que define o comportamento do comando GET.

  Recupera o valor de uma chave. 
  Caso a chave não exista, retorna `NIL`.

  Parâmetros:
    - `args`: Lista de strings contendo os argumentos passados na linha de comando. 
            Onde o primeiro, e único, argumento é a chave cujo valor será recuperado.
  Retorno: 
    - `{valor :: T, new_db :: Kvdb}`: 
      - `valor`: O valor associado com a chave. Onde `T` é o tipo do valor armazenado.
      - `new_db`: Uma nova instancia do nosso banco de dados
  """
  def get(db, key) do
    curr_transaction = get_top_transaction(db)
    {Map.get(curr_transaction, key, nil), db}
  end

  @doc """
  Função que define o comportamento do comando BEGIN.

  Inicia uma transação.

  Parâmetros:
    - Não recebe parâmetros.

  Retorno: 
    - `{nivel_de_transacao :: integer, new_db :: Kvdb}`: 
      - `nivel_de_transacao`: O nível de transação atual (i.e. quantas transações abertas existem).
      - `new_db`: Uma nova instancia do nosso banco de dados
  """
  def begin(db) do
    new_db = %Kvdb{transactions: [%{} | db.transactions]}
    {transaction_level(new_db), new_db}
  end

  @doc """
  Função que define o comportamento do comando ROLLBACK.

  Finaliza uma transação sem aplicar suas alterações.
  Isto é, todas as alterações feitas dentro da transação são descartadas.

  Parâmetros:
    - Não recebe parâmetros.

  Retorno: 
    - `{nivel_de_transacao :: integer, new_db :: Kvdb}`: 
      - `nivel_de_transacao`: O nível de transação após o rollback.
      - `new_db`: Uma nova instancia do banco de dados
  """
  def rollback(db) do
    case db.transactions do
      [_single_transaction] ->
        {transaction_level(db), db}

      [_ | remaining_transactions] ->
        new_db = %Kvdb{transactions: remaining_transactions}
        {transaction_level(new_db), new_db}

      _ ->
        {transaction_level(db), db}
    end
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
    - `{nivel_de_transacao :: integer, new_db :: Kvdb}`: 
      - `nivel_de_transacao`: O nível de transação após o commit.
      - `new_db`: Uma nova instancia do banco de dados
  """
  def commit(db) do
    raise "Not implemented yet"
  end
end
