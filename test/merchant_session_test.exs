defmodule StarkBankTest.MerchantSession do
  use ExUnit.Case

  @tag :merchant_session
  test "create merchant_session" do
    {:ok, session} = StarkBank.MerchantSession.create(example_merchant_session())
    assert !is_nil(session.id)
    assert !is_nil(session.uuid)
    assert !is_nil(session.status)
    assert length(session.allowed_installments) == 2

    Enum.each(session.allowed_installments, fn installment ->
      assert %StarkBank.MerchantSession.AllowedInstallment{} = installment
      assert !is_nil(installment.total_amount)
      assert !is_nil(installment.count)
    end)
  end

  @tag :merchant_session
  test "create! merchant_session" do
    session = StarkBank.MerchantSession.create!(example_merchant_session())
    assert !is_nil(session.id)
  end

  @tag :merchant_session
  test "query merchant_session" do
    StarkBank.MerchantSession.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :merchant_session
  test "query! merchant_session" do
    StarkBank.MerchantSession.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :merchant_session
  test "page merchant_session" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.MerchantSession.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_session
  test "page! merchant_session" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.MerchantSession.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_session
  test "get merchant_session" do
    session = StarkBank.MerchantSession.create!(example_merchant_session())
    {:ok, get_session} = StarkBank.MerchantSession.get(session.id)
    assert get_session.id == session.id
    assert get_session.uuid == session.uuid
  end

  @tag :merchant_session
  test "get! merchant_session" do
    session = StarkBank.MerchantSession.create!(example_merchant_session())
    get_session = StarkBank.MerchantSession.get!(session.id)
    assert get_session.id == session.id
  end

  @tag :merchant_session
  test "purchase merchant_session" do
    session = StarkBank.MerchantSession.create!(example_merchant_session("disabled"))

    {:ok, purchase} = StarkBank.MerchantSession.purchase(session.uuid, example_merchant_session_purchase())
    assert !is_nil(purchase.id)
    assert purchase.amount == 5000
    assert purchase.installment_count == 1
    assert !is_nil(purchase.status)
    assert !is_nil(purchase.card_ending)
  end

  @tag :merchant_session
  test "purchase! merchant_session" do
    session = StarkBank.MerchantSession.create!(example_merchant_session("disabled"))

    purchase = StarkBank.MerchantSession.purchase!(session.uuid, example_merchant_session_purchase())
    assert !is_nil(purchase.id)
    assert purchase.amount == 5000
    assert !is_nil(purchase.status)
  end

  def example_merchant_session(challenge_mode \\ "disabled") do
    %StarkBank.MerchantSession{
      allowed_funding_types: ["debit", "credit"],
      allowed_installments: [
        %StarkBank.MerchantSession.AllowedInstallment{total_amount: 5000, count: 1},
        %StarkBank.MerchantSession.AllowedInstallment{total_amount: 5500, count: 2}
      ],
      expiration: 3600,
      challenge_mode: challenge_mode,
      tags: ["yourTags"]
    }
  end

  def example_merchant_session_purchase() do
    # amount and installment_count must match one of the session's allowed_installments,
    # otherwise the API answers amountInstallmentCountMismatch
    %StarkBank.MerchantSession.Purchase{
      amount: 5000,
      installment_count: 1,
      card_expiration: "2035-01",
      card_number: "5277696455399733",
      card_security_code: "123",
      holder_name: "Holder Name",
      funding_type: "credit"
    }
  end
end
