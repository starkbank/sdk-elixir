defmodule StarkBankTest.CorporateCard.Log do
  use ExUnit.Case

  @tag :corporate_card_log
  test "get corporate card log" do
    logs = StarkBank.CorporateCard.Log.query!(limit: 10)
    |> Enum.take(1)
    |> hd

    {:ok, log} = StarkBank.CorporateCard.Log.get(logs.id)

    assert logs.id == log.id
  end

  @tag :corporate_card_log
  test "get! corporate card log" do
    logs = StarkBank.CorporateCard.Log.query!(limit: 10)
    |> Enum.take(1)
    |> hd

    log = StarkBank.CorporateCard.Log.get!(logs.id)

    assert logs.id == log.id
  end

  @tag :corporate_card_log
  test "query corporate card log" do
    StarkBank.CorporateCard.Log.query(limit: 101)
      |> Enum.take(200)
      |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_card_log
  test "query! corporate card log" do
    StarkBank.CorporateCard.Log.query!(limit: 1)
      |> Enum.take(5)
      |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :corporate_card_log
  test "page corporate card log" do
      {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkBank.CorporateCard.Log.page/1, 2, limit: 5)
      assert length(ids) <= 10
  end

  @tag :corporate_card_log
  test "page! corporate card log" do
      ids = StarkInfraTest.Utils.Page.get!(&StarkBank.CorporateCard.Log.page!/1, 2, limit: 5)
      assert length(ids) <= 10
  end
end
