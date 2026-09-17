defmodule StarkBankTest.CorporatePurchaseLog do
  use ExUnit.Case

  @tag :corporate_purchase_log
  test "query corporate_purchase log" do
    StarkBank.CorporatePurchase.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_purchase_log
  test "query! corporate_purchase log" do
    StarkBank.CorporatePurchase.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_purchase_log
  test "query! corporate_purchase log with filters" do
    purchase =
      StarkBank.CorporatePurchase.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.CorporatePurchase.Log.query!(limit: 1, purchase_ids: [purchase.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :corporate_purchase_log
  test "page corporate_purchase log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporatePurchase.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_purchase_log
  test "page! corporate_purchase log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporatePurchase.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_purchase_log
  test "get corporate_purchase log" do
    log =
      StarkBank.CorporatePurchase.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.CorporatePurchase.Log.get(log.id)
  end

  @tag :corporate_purchase_log
  test "get! corporate_purchase log" do
    log =
      StarkBank.CorporatePurchase.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.CorporatePurchase.Log.get!(log.id)
  end
end
