defmodule StarkBankTest.CorporateCard do
  use ExUnit.Case

  @tag :corporate_card
  test "create corporate_card" do
    {:ok, card} = StarkBank.CorporateCard.create(example_corporate_card())
    assert !is_nil(card)
  end

  @tag :corporate_card
  test "create! corporate_card" do
    card = StarkBank.CorporateCard.create!(example_corporate_card())
    assert !is_nil(card)
  end

  @tag :corporate_card
  test "create! corporate_card with expand" do
    card = StarkBank.CorporateCard.create!(example_corporate_card(), expand: ["rules", "security_code", "number", "expiration"])
    assert !is_nil(card.rules)
  end

  @tag :corporate_card
  test "query corporate_card" do
    StarkBank.CorporateCard.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_card
  test "query! corporate_card" do
    StarkBank.CorporateCard.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_card
  test "query corporate_card ids" do
    cards_ids_expected =
      StarkBank.CorporateCard.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, card} -> card.id end)

    assert length(cards_ids_expected) <= 10

    cards_ids_result =
      StarkBank.CorporateCard.query(ids: cards_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, card} -> card.id end)

    assert length(cards_ids_result) <= 10

    cards_ids_expected = Enum.sort(cards_ids_expected)
    cards_ids_result = Enum.sort(cards_ids_result)

    assert cards_ids_expected == cards_ids_result
  end

  @tag :corporate_card
  test "query! corporate_card ids" do
    cards_ids_expected =
      StarkBank.CorporateCard.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn card -> card.id end)

    assert length(cards_ids_expected) <= 10

    cards_ids_result =
      StarkBank.CorporateCard.query!(ids: cards_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn card -> card.id end)

    assert length(cards_ids_result) <= 10

    cards_ids_expected = Enum.sort(cards_ids_expected)
    cards_ids_result = Enum.sort(cards_ids_result)

    assert cards_ids_expected == cards_ids_result
  end

  @tag :corporate_card
  test "page corporate_card" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateCard.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_card
  test "page! corporate_card" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateCard.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_card
  test "get corporate_card" do
    card =
      StarkBank.CorporateCard.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _card} = StarkBank.CorporateCard.get(card.id)
  end

  @tag :corporate_card
  test "get! corporate_card" do
    card =
      StarkBank.CorporateCard.query!()
      |> Enum.take(1)
      |> hd()

    _card = StarkBank.CorporateCard.get!(card.id)
  end

  @tag :corporate_card
  test "get! corporate_card with expand" do
    card =
      StarkBank.CorporateCard.query!()
      |> Enum.take(1)
      |> hd()

    expanded_card = StarkBank.CorporateCard.get!(card.id, expand: ["rules"])
    assert !is_nil(expanded_card.rules)
  end

  @tag :corporate_card
  test "update and update! corporate_card" do
    first = StarkBank.CorporateCard.create!(example_corporate_card())
    second = StarkBank.CorporateCard.create!(example_corporate_card())

    {:ok, updated_card} = StarkBank.CorporateCard.update(first.id, display_name: "Updated Card")
    assert updated_card.display_name == "Updated Card"

    updated_card! = StarkBank.CorporateCard.update!(second.id, display_name: "Updated Card!")
    assert updated_card!.display_name == "Updated Card!"
  end

  @tag :corporate_card
  test "cancel and cancel! corporate_card" do
    first = StarkBank.CorporateCard.create!(example_corporate_card())
    second = StarkBank.CorporateCard.create!(example_corporate_card())

    {:ok, canceled_card} = StarkBank.CorporateCard.cancel(first.id)
    assert canceled_card.status == "canceled"

    canceled_card! = StarkBank.CorporateCard.cancel!(second.id)
    assert canceled_card!.status == "canceled"
  end

  def example_corporate_card() do
    holder =
      StarkBank.CorporateHolder.create!([
        %StarkBank.CorporateHolder{
          name: "Testerson Cardholder #{:rand.uniform(1_000_000)}",
          tags: ["Traveler Employee"],
          rules: [
            %StarkBank.CorporateRule{
              name: "General",
              interval: "week",
              amount: 100_000,
              currency_code: "BRL"
            }
          ]
        }
      ])
      |> hd

    %StarkBank.CorporateCard{holder_id: holder.id}
  end
end
