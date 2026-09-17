defmodule StarkBankTest.MerchantPurchaseLog do
  use ExUnit.Case

  @tag :merchant_purchase_log
  test "query merchant_purchase log" do
    StarkBank.MerchantPurchase.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_purchase_log
  test "query! merchant_purchase log" do
    StarkBank.MerchantPurchase.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_purchase_log
  test "query! merchant_purchase log with filters" do
    purchase =
      StarkBank.MerchantPurchase.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.MerchantPurchase.Log.query!(limit: 1, purchase_ids: [purchase.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :merchant_purchase_log
  test "page merchant_purchase log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.MerchantPurchase.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_purchase_log
  test "page! merchant_purchase log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.MerchantPurchase.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_purchase_log
  test "get merchant_purchase log" do
    log =
      StarkBank.MerchantPurchase.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.MerchantPurchase.Log.get(log.id)
  end

  @tag :merchant_purchase_log
  test "get! merchant_purchase log" do
    log =
      StarkBank.MerchantPurchase.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.MerchantPurchase.Log.get!(log.id)
  end
end
