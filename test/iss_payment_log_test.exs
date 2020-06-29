defmodule StarkBankTest.IssPaymentLog do
  use ExUnit.Case

  @tag :iss_payment_log
  test "query ISS payment log" do
    StarkBank.IssPayment.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :iss_payment_log
  test "query! ISS payment log" do
    StarkBank.IssPayment.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :iss_payment_log
  test "query! ISS payment log with filters" do
    payment =
      StarkBank.IssPayment.query!(status: "failed")
      |> Enum.take(1)
      |> hd()

    StarkBank.IssPayment.Log.query!(limit: 1, payment_ids: [payment.id], types: "failed")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :iss_payment_log
  test "get ISS payment log" do
    log =
      StarkBank.IssPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.IssPayment.Log.get(log.id)
  end

  @tag :iss_payment_log
  test "get! ISS payment log" do
    log =
      StarkBank.IssPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.IssPayment.Log.get!(log.id)
  end
end
