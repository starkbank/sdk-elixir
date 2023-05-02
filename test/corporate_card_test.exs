defmodule StarkBankTest.CorporateCard do
  use ExUnit.Case

  @tag :corporate_card
  test "query corporate card test" do
    {:ok, corporate_card} = StarkBank.CorporateCard.query(limit: 10)
      |> Enum.take(1)
      |> hd

    assert !is_nil(corporate_card.id)
  end

  @tag :corporate_card
  test "query! corporate card test" do
    corporate_card = StarkBank.CorporateCard.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    assert !is_nil(corporate_card.id)
  end

  @tag :corporate_card
  test "page corporate card test" do
    {:ok, {_cursor, corporate_cards}} = StarkBank.CorporateCard.page(limit: 10)
    corporate_card = corporate_cards |> Enum.take(1) |> hd

    assert !is_nil(corporate_card.id)
  end

  @tag :corporate_card
  test "page! corporate card test" do
    {_cursor, corporate_cards} = StarkBank.CorporateCard.page!(limit: 10)
    corporate_card = corporate_cards |> Enum.take(1) |> hd

    assert !is_nil(corporate_card.id)
  end

  @tag :corporate_card
  test "create corporate card test" do
    {:ok, corporate_card} = StarkBank.CorporateCard.create(
      [example_corporate_card()],
      expand: ["rules", "securityCode", "number", "expiration"]
    )
    corporate_card = corporate_card |> Enum.take(1) |> hd

    {:ok, card} = StarkBank.CorporateCard.get(corporate_card.id)

    assert !is_nil(card.id)
  end

  @tag :corporate_card
  test "create! corporate card test" do
    corporate_card = StarkBank.CorporateCard.create!(
      [example_corporate_card()],
      expand: ["rules", "securityCode", "number", "expiration"]
    )
    corporate_card = corporate_card |> Enum.take(1) |> hd

    {:ok, card} = StarkBank.CorporateCard.get(corporate_card.id)

    assert !is_nil(card.id)
  end

  @tag :corporate_card
  test "update corporate card test" do
    corporate_card = StarkBank.CorporateCard.create!([example_corporate_card()])
    corporate_card = corporate_card |> Enum.take(1) |> hd

    parameters = %{status: "blocked"}
    {:ok, card} = StarkBank.CorporateCard.update(corporate_card.id, parameters)

    assert card.status == "blocked"
  end

  @tag :corporate_card
  test "update! corporate card test" do
    corporate_card = StarkBank.CorporateCard.create!([example_corporate_card()])
    corporate_card = corporate_card |> Enum.take(1) |> hd

    parameters = %{status: "blocked"}
    card = StarkBank.CorporateCard.update!(corporate_card.id, parameters)

    assert card.status == "blocked"
  end

  @tag :corporate_card
  test "cancel corporate card test" do
    corporate_card = StarkBank.CorporateCard.create!([example_corporate_card()])
    corporate_card = corporate_card |> Enum.take(1) |> hd

    {:ok, deleted_corporate_card} = StarkBank.CorporateCard.cancel(corporate_card.id)
    assert deleted_corporate_card.status == "canceled"
  end

  @tag :corporate_card
  test "cancel! corporate card test" do
    corporate_card = StarkBank.CorporateCard.create!([example_corporate_card()])
    corporate_card = corporate_card |> Enum.take(1) |> hd

    deleted_corporate_card = StarkBank.CorporateCard.cancel!(corporate_card.id)
    assert deleted_corporate_card.status == "canceled"
  end

  def example_corporate_card do
    StarkBank.CorporateHolder.query!(limit: 10)
      |> Enum.take(1)
      |> hd
      |> build_example
  end

  def build_example(holder) do
    %StarkBank.CorporateCard{
      city: "Sao Paulo",
      display_name: "ANTHONY STARK",
      district: "Bela Vista",
      holder_id: holder.holder_id,
      holder_name: holder.name,
      rules: [
        %StarkBank.CorporateRule{
          amount: 900000,
          currency_code: "BRL",
          interval: "week",
          name: "Example Rule"
        }
      ],
      state_code: "SP",
      street_line_1: "Av. Paulista, 200",
      street_line_2: "Apto. 123",
      tags: ["travel", "food"],
      zip_code: "01311-200"
    }
  end
end
