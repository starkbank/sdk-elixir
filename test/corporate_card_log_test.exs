defmodule StarkBankTest.CorporateCardLog do
  use ExUnit.Case

  @tag :corporate_card_log
  test "query corporate_card log" do
    StarkBank.CorporateCard.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_card_log
  test "query! corporate_card log" do
    StarkBank.CorporateCard.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_card_log
  test "query! corporate_card log with filters" do
    card =
      StarkBank.CorporateCard.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.CorporateCard.Log.query!(limit: 1, card_ids: [card.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :corporate_card_log
  test "page corporate_card log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateCard.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_card_log
  test "page! corporate_card log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateCard.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_card_log
  test "get corporate_card log" do
    log =
      StarkBank.CorporateCard.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.CorporateCard.Log.get(log.id)
  end

  @tag :corporate_card_log
  test "get! corporate_card log" do
    log =
      StarkBank.CorporateCard.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.CorporateCard.Log.get!(log.id)
  end
end
