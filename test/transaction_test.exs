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

  defp example_transaction() do
    %StarkBank.Transaction{
      amount: 1,
      receiver_id: "5768064935133184",
      external_id: :crypto.strong_rand_bytes(30) |> Base.url_encode64() |> binary_part(0, 30),
      description: "Transferencia para Workspace aleatorio"
    }
  end
end
