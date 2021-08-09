defmodule StarkBankTest.Transaction do
  use ExUnit.Case

  @tag :transaction
  test "create transaction" do
    {:ok, transactions} = StarkBank.Transaction.create([example_transaction()])
    transaction = transactions |> hd
    assert transaction.amount < 0
  end

  @tag :transaction
  test "create! transaction" do
    transaction = StarkBank.Transaction.create!([example_transaction()]) |> hd
    assert transaction.amount < 0
  end

  @tag :transaction
  test "query transaction" do
    StarkBank.Transaction.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :transaction
  test "query! transaction" do
    StarkBank.Transaction.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :transaction
  test "query transaction ids" do
    transactions_ids_expected =
      StarkBank.Transaction.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, transaction} -> transaction.id end)

    assert length(transactions_ids_expected) <= 10

    transactions_ids_result =
      StarkBank.Transaction.query(ids: transactions_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, transaction} -> transaction.id end)

    assert length(transactions_ids_result) <= 10

    transactions_ids_expected = Enum.sort(transactions_ids_expected)
    transactions_ids_result = Enum.sort(transactions_ids_result)

    assert transactions_ids_expected == transactions_ids_result
  end

  @tag :transaction
  test "query! transaction ids" do
    transactions_ids_expected =
      StarkBank.Transaction.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn transaction -> transaction.id end)

    assert length(transactions_ids_expected) <= 10

    transactions_ids_result =
      StarkBank.Transaction.query!(ids: transactions_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn transaction -> transaction.id end)

    assert length(transactions_ids_result) <= 10

    transactions_ids_expected = Enum.sort(transactions_ids_expected)
    transactions_ids_result = Enum.sort(transactions_ids_result)

    assert transactions_ids_expected == transactions_ids_result
  end

  @tag :transaction
  test "page transaction" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Transaction.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :transaction
  test "page! transaction" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Transaction.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :transaction
  test "get transaction" do
    transaction =
      StarkBank.Transaction.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _transaction} = StarkBank.Transaction.get(transaction.id)
  end

  @tag :transaction
  test "get! transaction" do
    transaction =
      StarkBank.Transaction.query!()
      |> Enum.take(1)
      |> hd()

    _transaction = StarkBank.Transaction.get!(transaction.id)
  end

  def example_transaction() do
    %StarkBank.Transaction{
      amount: 1,
      receiver_id: "5768064935133184",
      external_id: :crypto.strong_rand_bytes(30) |> Base.url_encode64() |> binary_part(0, 30),
      description: "Transferencia para Workspace aleatorio"
    }
  end
end
