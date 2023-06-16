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
  test "get corporate card test" do
    {:ok, q_corporate_card} = StarkBank.CorporateCard.query(limit: 10)
      |> Enum.take(1)
      |> hd

    {:ok, corporate_card} = StarkBank.CorporateCard.get(q_corporate_card.id)

    assert !is_nil(corporate_card.id)
  end

  @tag :corporate_card
  test "get! corporate card test" do
    q_corporate_card = StarkBank.CorporateCard.query!(limit: 1)
      |> Enum.take(1)
      |> hd

    corporate_card = StarkBank.CorporateCard.get!(q_corporate_card.id)

    assert !is_nil(corporate_card.id)
  end

  # @tag :corporate_card
  # test "create corporate card test" do
  #   {:ok, corporate_card} = StarkBank.CorporateCard.create(
  #     [example_corporate_card()],
  #     expand: ["rules", "securityCode", "number", "expiration"]
  #   )
  #   corporate_card = corporate_card |> IO.inspect |> Enum.take(1) |> hd |> IO.inspect

  #   {:ok, card} = StarkBank.CorporateCard.get(corporate_card.id)

  #   assert !is_nil(card.id)
  # end

  # @tag :corporate_card
  # test "create! corporate card test" do
  #   corporate_card = StarkBank.CorporateCard.create!(
  #     [example_corporate_card()],
  #     expand: ["rules", "securityCode", "number", "expiration"]
  #   )
  #   corporate_card = corporate_card |> Enum.take(1) |> hd

  #   {:ok, card} = StarkBank.CorporateCard.get(corporate_card.id)

  #   assert !is_nil(card.id)
  # end

  # @tag :corporate_card
  # test "update corporate card test" do
  #   corporate_card = StarkBank.CorporateCard.create!([example_corporate_card()])
  #   corporate_card = corporate_card |> Enum.take(1) |> hd

  #   parameters = %{status: "blocked"}
  #   {:ok, card} = StarkBank.CorporateCard.update(corporate_card.id, parameters)

  #   assert card.status == "blocked"
  # end

  # @tag :corporate_card
  # test "update! corporate card test" do
  #   corporate_card = StarkBank.CorporateCard.create!([example_corporate_card()])
  #   corporate_card = corporate_card |> Enum.take(1) |> hd

  #   parameters = %{status: "blocked"}
  #   card = StarkBank.CorporateCard.update!(corporate_card.id, parameters)

  #   assert card.status == "blocked"
  # end

  # @tag :corporate_card
  # test "cancel corporate card test" do
  #   corporate_card = StarkBank.CorporateCard.create!([example_corporate_card()])
  #   corporate_card = corporate_card |> Enum.take(1) |> hd

  #   {:ok, deleted_corporate_card} = StarkBank.CorporateCard.cancel(corporate_card.id)
  #   assert deleted_corporate_card.status == "canceled"
  # end

  # @tag :corporate_card
  # test "cancel! corporate card test" do
  #   corporate_card = StarkBank.CorporateCard.create!([example_corporate_card()])
  #   corporate_card = corporate_card |> Enum.take(1) |> hd

  #   deleted_corporate_card = StarkBank.CorporateCard.cancel!(corporate_card.id)
  #   assert deleted_corporate_card.status == "canceled"
  # end

  def example_corporate_card do
    StarkBank.CorporateHolder.query!(limit: 10)
      |> Enum.take(1)
      |> hd |> IO.inspect
      |> build_example
  end

  def build_example(holder) do
    %StarkBank.CorporateCard{
      holder_id: "5768527969517568",
    }
  end
end
