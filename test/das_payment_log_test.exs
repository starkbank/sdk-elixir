defmodule StarkBankTest.DasPaymentLog do
  use ExUnit.Case

  @tag :das_payment_log
  test "query DAS payment log" do
    StarkBank.DasPayment.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :das_payment_log
  test "query! DAS payment log" do
    StarkBank.DasPayment.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :das_payment_log
  test "query! DAS payment log with filters" do
    payment =
      StarkBank.DasPayment.query!(status: "failed")
      |> Enum.take(1)
      |> hd()

    StarkBank.DasPayment.Log.query!(limit: 1, payment_ids: [payment.id], types: "failed")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :das_payment_log
  test "get DAS payment log" do
    log =
      StarkBank.DasPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.DasPayment.Log.get(log.id)
  end

  @tag :das_payment_log
  test "get! DAS payment log" do
    log =
      StarkBank.DasPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.DasPayment.Log.get!(log.id)
  end
end
