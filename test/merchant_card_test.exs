defmodule StarkBankTest.MerchantCard do
  use ExUnit.Case

  @tag :merchant_card
  test "query merchant_card" do
    StarkBank.MerchantCard.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_card
  test "query! merchant_card" do
    StarkBank.MerchantCard.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_card
  test "query merchant_card ids" do
    cards_ids_expected =
      StarkBank.MerchantCard.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, card} -> card.id end)

    assert length(cards_ids_expected) <= 10

    cards_ids_result =
      StarkBank.MerchantCard.query(ids: cards_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, card} -> card.id end)

    assert length(cards_ids_result) <= 10

    cards_ids_expected = Enum.sort(cards_ids_expected)
    cards_ids_result = Enum.sort(cards_ids_result)

    assert cards_ids_expected == cards_ids_result
  end

  @tag :merchant_card
  test "query! merchant_card ids" do
    cards_ids_expected =
      StarkBank.MerchantCard.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn card -> card.id end)

    assert length(cards_ids_expected) <= 10

    cards_ids_result =
      StarkBank.MerchantCard.query!(ids: cards_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn card -> card.id end)

    assert length(cards_ids_result) <= 10

    cards_ids_expected = Enum.sort(cards_ids_expected)
    cards_ids_result = Enum.sort(cards_ids_result)

    assert cards_ids_expected == cards_ids_result
  end

  @tag :merchant_card
  test "page merchant_card" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.MerchantCard.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_card
  test "page! merchant_card" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.MerchantCard.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_card
  test "get merchant_card" do
    card =
      StarkBank.MerchantCard.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _card} = StarkBank.MerchantCard.get(card.id)
  end

  @tag :merchant_card
  test "get! merchant_card" do
    card =
      StarkBank.MerchantCard.query!()
      |> Enum.take(1)
      |> hd()

    _card = StarkBank.MerchantCard.get!(card.id)
  end
end
