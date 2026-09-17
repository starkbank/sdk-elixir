defmodule StarkBankTest.MerchantCardLog do
  use ExUnit.Case

  @tag :merchant_card_log
  test "query merchant_card log" do
    StarkBank.MerchantCard.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_card_log
  test "query! merchant_card log" do
    StarkBank.MerchantCard.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_card_log
  test "query! merchant_card log with filters" do
    card =
      StarkBank.MerchantCard.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.MerchantCard.Log.query!(limit: 1, card_ids: [card.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :merchant_card_log
  test "page merchant_card log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.MerchantCard.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_card_log
  test "page! merchant_card log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.MerchantCard.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_card_log
  test "get merchant_card log" do
    log =
      StarkBank.MerchantCard.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.MerchantCard.Log.get(log.id)
  end

  @tag :merchant_card_log
  test "get! merchant_card log" do
    log =
      StarkBank.MerchantCard.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.MerchantCard.Log.get!(log.id)
  end
end
