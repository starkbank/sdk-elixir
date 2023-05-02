defmodule StarkBankTest.CorporatePurchase.Log do
  use ExUnit.Case

  @tag :corporate_purchase_log
  test "get corporate purchase log" do
    logs = StarkBank.CorporatePurchase.Log.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    {:ok, log} = StarkBank.CorporatePurchase.Log.get(logs.id)

    assert logs.id == log.id
  end

  @tag :corporate_purchase_log
  test "get! corporate purchase log" do
    logs = StarkBank.CorporatePurchase.Log.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    log = StarkBank.CorporatePurchase.Log.get!(logs.id)

    assert logs.id == log.id
  end

  @tag :corporate_purchase_log
  test "query corporate purchase log" do
    StarkBank.CorporatePurchase.Log.query(limit: 101)
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_purchase_log
  test "page corporate purchase log" do
      {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporatePurchase.Log.page/1, 2, limit: 5)
      assert length(ids) <= 10
  end

  @tag :corporate_purchase_log
  test "page! corporate purchase log" do
      ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporatePurchase.Log.page!/1, 2, limit: 5)
      assert length(ids) <= 10
  end
end
