defmodule StarkBankTest.PaymentRequest do
  use ExUnit.Case

  @tag :payment_request
  test "create! PaymentRequest" do
    requests = for i <- 1..10, i > 0 do
      request_example()
    end
    received = StarkBank.PaymentRequest.create!(requests)
    for item <- received do
      assert !is_nil(item.id)
    end
  end

  @tag :payment_request
  test "create PaymentRequest" do
    requests = for i <- 1..10, i > 0 do
      request_example()
    end
    {:ok, received} = StarkBank.PaymentRequest.create(requests)
    for item <- received do
      assert !is_nil(item.id)
    end
  end

  @tag :payment_request
  test "query payment request" do
    StarkBank.PaymentRequest.query(center_id: System.get_env("SANDBOX_CENTER_ID"), limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :payment_request
  test "query! payment request" do
    StarkBank.PaymentRequest.query!(center_id: System.get_env("SANDBOX_CENTER_ID"), limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :payment_request
  test "page payment request" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.PaymentRequest.page/1, 2, center_id: System.get_env("SANDBOX_CENTER_ID"), limit: 5)
    assert length(ids) == 10
  end

  @tag :payment_request
  test "page! payment request" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.PaymentRequest.page!/1, 2, center_id: System.get_env("SANDBOX_CENTER_ID"), limit: 5)
    assert length(ids) == 10
  end

  def request_example() do
    payment = create_payment()
    %StarkBank.PaymentRequest{
      center_id: System.get_env("SANDBOX_CENTER_ID"),
      payment: payment,
      due: get_due_date(payment)
    }
  end

  defp get_days() do
    days = Enum.random(1..7)
    Date.utc_today() |> Date.add(days)
  end

  defp get_due_date(payment) do
    case payment do
      %StarkBank.Transfer{} -> get_days()
      %StarkBank.BoletoPayment{} -> get_days()
      %StarkBank.UtilityPayment{} -> get_days()
      %StarkBank.BrcodePayment{} -> get_days()
      %StarkBank.Transaction{} -> nil
    end
  end

  defp create_payment() do
    case Enum.random(0..4) do
      0 -> StarkBankTest.Transfer.example_transfer(false)
      1 -> StarkBankTest.Transaction.example_transaction()
      2 -> StarkBankTest.BoletoPayment.example_payment(false)
      3 -> StarkBankTest.UtilityPayment.example_payment(false)
      4 -> StarkBankTest.BrcodePayment.example_payment(false)
    end
  end
end
