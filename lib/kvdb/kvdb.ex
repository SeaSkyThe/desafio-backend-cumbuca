defmodule Kvdb do
  @moduledoc """
  Módulo responsável por definir a estrutura principal do banco.
  Kvdb = Key-Value Database
  """

  defstruct transactions: [], filename: nil

  def new(filename \\ nil, load \\ false) do
    if load && filename do
      load_state(filename)
    else
      %Kvdb{transactions: [%{}], filename: filename}
    end
  end

  def get_top_transaction(db) do
    [last | _] = db.transactions
    last
  end

  def transaction_level(db) do
    length(db.transactions) - 1
  end

  def update_top_transaction(db, new_transaction) do
    # Personal Remainder: the update syntax is confusing 
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

    save_state(new_db)

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
    new_db = %{db | transactions: [%{} | db.transactions]}
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
        new_db = %{db | transactions: remaining_transactions}
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
  devem ser efetivados no banco.

  Parâmetros:
    - Não recebe parâmetros.

  Retorno: 
    - `{nivel_de_transacao :: integer, new_db :: Kvdb}`: 
      - `nivel_de_transacao`: O nível de transação após o commit.
      - `new_db`: Uma nova instancia do banco de dados
  """
  def commit(db) do
    case db.transactions do
      [_single_transaction] ->
        {transaction_level(db), db}

      [current_transaction, superior_transaction | remaining_transactions] ->
        new_superior_transaction = Map.merge(superior_transaction, current_transaction)
        new_db = %{db | transactions: [new_superior_transaction | remaining_transactions]}
        save_state(new_db)
        {transaction_level(new_db), new_db}
    end
  end

  defp save_state(db) do
    if transaction_level(db) == 0 do
      case db.filename do
        nil ->
          :ok

        _ ->
          persistence_file = db.filename
          level_0_transaction = List.last(db.transactions)

          data_to_save = Map.to_list(level_0_transaction)

          case File.open(persistence_file, [:write]) do
            {:ok, file} ->
              try do
                Enum.each(
                  data_to_save,
                  fn {key, value} ->
                    key_len = String.length(key)

                    case value do
                      value when is_integer(value) ->
                        IO.write(file, "#{key_len} #{key} #{value} int\n")

                      value when is_boolean(value) ->
                        IO.write(file, "#{key_len} #{key} #{value} bool\n")

                      _ ->
                        IO.write(file, "#{key_len} #{key} #{value} str\n")
                    end
                  end
                )

                :ok
              after
                :file.close(file)
              end

            {:error, reason} ->
              {:error, reason}
          end
      end
    else
      :ok
    end
  end

  defp load_state(filename) do
    case File.read(filename) do
      {:ok, text} ->
        values = String.split(text, "\n", trim: true)

        # {_, values} = List.pop_at(values_with_last, -1)

        level_0_transaction =
          Enum.reduce(values, %{}, fn line, acc ->
            {key, value, type} = parse_line(line)
            Map.put(acc, key, cast_value(value, type))
          end)

        %Kvdb{transactions: [level_0_transaction], filename: filename}

      {:error, _reason} ->
        %Kvdb{transactions: [%{}], filename: filename}
    end
  end

  defp parse_line(line) do
    [key_size_str | rest] = String.split(line, " ", parts: 2, trim: true)

    rest = List.first(rest)

    key_size = String.to_integer(key_size_str)
    key = String.slice(rest, 0..(key_size - 1))

    value_and_type_string = String.slice(rest, key_size..-1//1)
    value_and_type = String.split(value_and_type_string, " ", trim: true)

    type = List.last(value_and_type)
    value = Enum.slice(value_and_type, 0..(length(value_and_type) - 2)) |> Enum.join(" ")

    {key, value, type}
  end

  defp cast_value(value, "int"), do: String.to_integer(value)
  defp cast_value("true", "bool"), do: true
  defp cast_value("false", "bool"), do: false
  defp cast_value(value, "str"), do: value
end
