defmodule StarkBankTest.UtilityPaymentLog do
  use ExUnit.Case

  @tag :utility_payment_log
  test "query utility payment log" do
    StarkBank.UtilityPayment.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :utility_payment_log
  test "query! utility payment log" do
    StarkBank.UtilityPayment.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :utility_payment_log
  test "query! utility payment log with filters" do
    payment =
      StarkBank.UtilityPayment.query!(status: "failed")
      |> Enum.take(1)
      |> hd()

    StarkBank.UtilityPayment.Log.query!(limit: 1, payment_ids: [payment.id], types: "failed")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :utility_payment_log
  test "get utility payment log" do
    log =
      StarkBank.UtilityPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.UtilityPayment.Log.get(log.id)
  end

  @tag :utility_payment_log
  test "get! utility payment log" do
    log =
      StarkBank.UtilityPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.UtilityPayment.Log.get!(log.id)
  end
end
