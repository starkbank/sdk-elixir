defmodule StarkBankTest.CorporatePurchase do
  use ExUnit.Case

  @tag :corporate_purchase
  test "query corporate purchase test" do
    corporate_purchases = StarkBank.CorporatePurchase.query(limit: 10)
      |> Enum.take(10)

    Enum.each(corporate_purchases, fn purchase ->
      {:ok, purchase} = purchase
      assert purchase.id == StarkBank.CorporatePurchase.get!(purchase.id).id
    end)

    assert length(corporate_purchases) <= 10
  end

  @tag :corporate_purchase
  test "query! corporate purchase test" do
    corporate_purchases = StarkBank.CorporatePurchase.query!(limit: 10)
      |> Enum.take(10)

    Enum.each(corporate_purchases, fn purchase ->
      assert purchase.id == StarkBank.CorporatePurchase.get!(purchase.id).id
    end)

    assert length(corporate_purchases) <= 10
  end

  @tag :corporate_purchase
  test "page corporate purchase test" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkBank.CorporatePurchase.page/1, 2, limit: 5)
    assert length(ids) <= 10

    Enum.each(ids, fn id ->
      {:ok, purchase} = StarkBank.CorporatePurchase.get(id)
      assert purchase.id == id
    end)

  end

  @tag :corporate_purchase
  test "page! corporate purchase test" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkBank.CorporatePurchase.page!/1, 2, limit: 5)
    assert length(ids) <= 10

    Enum.each(ids, fn id ->
      assert id == StarkBank.CorporatePurchase.get!(id).id
    end)
  end
end
