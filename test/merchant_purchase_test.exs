defmodule StarkBankTest.MerchantPurchase do
  use ExUnit.Case

  @tag :merchant_purchase
  test "create merchant_purchase" do
    {:ok, purchase} = StarkBank.MerchantPurchase.create(example_merchant_purchase())
    assert !is_nil(purchase.id)
  end

  @tag :merchant_purchase
  test "create! merchant_purchase" do
    purchase = StarkBank.MerchantPurchase.create!(example_merchant_purchase())
    assert !is_nil(purchase.id)
  end

  @tag :merchant_purchase
  test "query merchant_purchase" do
    StarkBank.MerchantPurchase.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_purchase
  test "query! merchant_purchase" do
    StarkBank.MerchantPurchase.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_purchase
  test "query merchant_purchase ids" do
    purchases_ids_expected =
      StarkBank.MerchantPurchase.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, purchase} -> purchase.id end)

    assert length(purchases_ids_expected) <= 10

    purchases_ids_result =
      StarkBank.MerchantPurchase.query(ids: purchases_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, purchase} -> purchase.id end)

    assert length(purchases_ids_result) <= 10

    purchases_ids_expected = Enum.sort(purchases_ids_expected)
    purchases_ids_result = Enum.sort(purchases_ids_result)

    assert purchases_ids_expected == purchases_ids_result
  end

  @tag :merchant_purchase
  test "query! merchant_purchase ids" do
    purchases_ids_expected =
      StarkBank.MerchantPurchase.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn purchase -> purchase.id end)

    assert length(purchases_ids_expected) <= 10

    purchases_ids_result =
      StarkBank.MerchantPurchase.query!(ids: purchases_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn purchase -> purchase.id end)

    assert length(purchases_ids_result) <= 10

    purchases_ids_expected = Enum.sort(purchases_ids_expected)
    purchases_ids_result = Enum.sort(purchases_ids_result)

    assert purchases_ids_expected == purchases_ids_result
  end

  @tag :merchant_purchase
  test "page merchant_purchase" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.MerchantPurchase.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_purchase
  test "page! merchant_purchase" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.MerchantPurchase.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_purchase
  test "get merchant_purchase" do
    purchase =
      StarkBank.MerchantPurchase.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _purchase} = StarkBank.MerchantPurchase.get(purchase.id)
  end

  @tag :merchant_purchase
  test "get! merchant_purchase" do
    purchase =
      StarkBank.MerchantPurchase.query!()
      |> Enum.take(1)
      |> hd()

    _purchase = StarkBank.MerchantPurchase.get!(purchase.id)
  end

  @tag :merchant_purchase
  test "update! merchant_purchase" do
    purchase =
      StarkBank.MerchantPurchase.query!(status: "confirmed", limit: 1)
      |> Enum.take(1)
      |> hd()

    updated_purchase = StarkBank.MerchantPurchase.update!(purchase.id, status: "reversed", amount: 0)
    assert updated_purchase.id == purchase.id
  end

  @tag :merchant_purchase
  test "update merchant_purchase" do
    purchase =
      StarkBank.MerchantPurchase.query!(status: "confirmed", limit: 1)
      |> Enum.take(1)
      |> hd()

    {:ok, updated_purchase} = StarkBank.MerchantPurchase.update(purchase.id, status: "reversed", amount: 0)
    assert updated_purchase.id == purchase.id
  end

  def example_merchant_purchase() do
    confirmed_purchase =
      StarkBank.MerchantPurchase.query!(status: "confirmed", limit: 1)
      |> Enum.take(1)
      |> hd()

    %StarkBank.MerchantPurchase{
      amount: 5000,
      card_id: confirmed_purchase.card_id,
      funding_type: "credit",
      installment_count: 1
    }
  end
end
