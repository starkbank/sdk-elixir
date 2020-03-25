defmodule StarkBankTest.Transaction do
  use ExUnit.Case

  @tag :exclude
  test "create transaction" do
    user = StarkBankTest.Credentials.project()
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

  @tag :exclude
  test "create! transaction" do
    user = StarkBankTest.Credentials.project()
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

  @tag :exclude
  test "query transaction" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Transaction.query(user, limit: 150)
     |> Enum.take(150)
     |> (fn list -> assert length(list) == 150 end).()
  end

  @tag :exclude
  test "query! transaction" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Transaction.query!(user, limit: 150)
     |> Enum.take(150)
     |> (fn list -> assert length(list) == 150 end).()
  end

  @tag :exclude
  test "get transaction" do
    user = StarkBankTest.Credentials.project()
    transaction = StarkBank.Transaction.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _transaction} = StarkBank.Transaction.get(user, transaction.id)
  end

  @tag :exclude
  test "get! transaction" do
    user = StarkBankTest.Credentials.project()
    transaction = StarkBank.Transaction.query!(user)
     |> Enum.take(1)
     |> hd()
    _transaction = StarkBank.Transaction.get!(user, transaction.id)
  end
end
