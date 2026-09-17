defmodule StarkBankTest.CorporatePurchase do
  use ExUnit.Case

  @tag :corporate_purchase
  test "query corporate_purchase" do
    StarkBank.CorporatePurchase.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_purchase
  test "query! corporate_purchase" do
    StarkBank.CorporatePurchase.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_purchase
  test "query corporate_purchase ids" do
    purchases_ids_expected =
      StarkBank.CorporatePurchase.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, purchase} -> purchase.id end)

    assert length(purchases_ids_expected) <= 10

    purchases_ids_result =
      StarkBank.CorporatePurchase.query(ids: purchases_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, purchase} -> purchase.id end)

    assert length(purchases_ids_result) <= 10

    purchases_ids_expected = Enum.sort(purchases_ids_expected)
    purchases_ids_result = Enum.sort(purchases_ids_result)

    assert purchases_ids_expected == purchases_ids_result
  end

  @tag :corporate_purchase
  test "query! corporate_purchase ids" do
    purchases_ids_expected =
      StarkBank.CorporatePurchase.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn purchase -> purchase.id end)

    assert length(purchases_ids_expected) <= 10

    purchases_ids_result =
      StarkBank.CorporatePurchase.query!(ids: purchases_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn purchase -> purchase.id end)

    assert length(purchases_ids_result) <= 10

    purchases_ids_expected = Enum.sort(purchases_ids_expected)
    purchases_ids_result = Enum.sort(purchases_ids_result)

    assert purchases_ids_expected == purchases_ids_result
  end

  @tag :corporate_purchase
  test "page corporate_purchase" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporatePurchase.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_purchase
  test "page! corporate_purchase" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporatePurchase.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_purchase
  test "get corporate_purchase" do
    purchase =
      StarkBank.CorporatePurchase.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _purchase} = StarkBank.CorporatePurchase.get(purchase.id)
  end

  @tag :corporate_purchase
  test "get! corporate_purchase" do
    purchase =
      StarkBank.CorporatePurchase.query!()
      |> Enum.take(1)
      |> hd()

    _purchase = StarkBank.CorporatePurchase.get!(purchase.id)
  end
end
