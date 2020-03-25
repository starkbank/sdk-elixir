defmodule StarkbankTest.Transaction do
  use ExUnit.Case

  @tag :skip
  test "create transaction" do
    user = StarkbankTest.Credentials.project()
    {:ok, transactions} = StarkBank.Transaction.create(user, [
      %StarkBank.Transaction.Data{
        amount: 1,
        receiver_id: "5768064935133184",
        external_id: external_id(),
        description: "Transferencia para Workspace aleatorio"
      }
    ])
    transaction = transactions |> hd
    assert transaction.amount < 0
  end

  @tag :skip
  test "create! transaction" do
    user = StarkbankTest.Credentials.project()
    transaction = StarkBank.Transaction.create!(user, [
      %StarkBank.Transaction.Data{
        amount: 1,
        receiver_id: "5768064935133184",
        external_id: external_id(),
        description: "Transferencia para Workspace aleatorio"
      }
    ]) |> hd
    assert transaction.amount < 0
  end

  defp external_id() do
    :crypto.strong_rand_bytes(30) |> Base.url_encode64 |> binary_part(0, 30)
  end

  @tag :skip
  test "query transaction" do
    user = StarkbankTest.Credentials.project()
    StarkBank.Transaction.query(user, limit: 150)
     |> Enum.take(150)
     |> (fn list -> assert length(list) == 150 end).()
  end

  @tag :skip
  test "query! transaction" do
    user = StarkbankTest.Credentials.project()
    StarkBank.Transaction.query!(user, limit: 150)
     |> Enum.take(150)
     |> (fn list -> assert length(list) == 150 end).()
  end

  @tag :skip
  test "get transaction" do
    user = StarkbankTest.Credentials.project()
    transaction = StarkBank.Transaction.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _transaction} = StarkBank.Transaction.get(user, transaction.id)
  end

  @tag :skip
  test "get! transaction" do
    user = StarkbankTest.Credentials.project()
    transaction = StarkBank.Transaction.query!(user)
     |> Enum.take(1)
     |> hd()
    _transaction = StarkBank.Transaction.get!(user, transaction.id)
  end
end
