defmodule StarkBankTest.UtilityPaymentLog do
  use ExUnit.Case

  @tag :exclude
  test "query utility payment log" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Utility.Log.query(user, limit: 101)
     |> Enum.take(101)
     |> (fn list -> assert length(list) == 101 end).()
  end

  @tag :exclude
  test "query! utility payment log" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Utility.Log.query!(user, limit: 101)
     |> Enum.take(101)
     |> (fn list -> assert length(list) == 101 end).()
  end

  @tag :exclude
  test "query! utility payment log with filters" do
    user = StarkBankTest.Credentials.project()

    payment = StarkBank.Payment.Utility.query!(user, status: "success")
     |> Enum.take(1)
     |> hd()

    StarkBank.Payment.Utility.Log.query!(user, limit: 1, payment_ids: [payment.id], types: "success")
     |> Enum.take(5)
     |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :exclude
  test "get utility payment log" do
    user = StarkBankTest.Credentials.project()
    log = StarkBank.Payment.Utility.Log.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _log} = StarkBank.Payment.Utility.Log.get(user, log.id)
  end

  @tag :exclude
  test "get! utility payment log" do
    user = StarkBankTest.Credentials.project()
    log = StarkBank.Payment.Utility.Log.query!(user)
     |> Enum.take(1)
     |> hd()
    _log = StarkBank.Payment.Utility.Log.get!(user, log.id)
  end
end
