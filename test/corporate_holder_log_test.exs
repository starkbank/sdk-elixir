defmodule StarkBankTest.CorporateHolder.Log do
  use ExUnit.Case

  @tag :corporate_holder_log
  test "get corporate holder log" do
    logs = StarkBank.CorporateHolder.Log.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    {:ok, log} = StarkBank.CorporateHolder.Log.get(logs.id)
    assert logs.id == log.id
  end

  @tag :corporate_holder_log
  test "get! corporate holder log" do
    logs = StarkBank.CorporateHolder.Log.query!(limit: 10)
      |> Enum.take(1)
      |> hd

    log = StarkBank.CorporateHolder.Log.get!(logs.id)

    assert logs.id == log.id
  end

  @tag :corporate_holder_log
  test "query corporate holder log" do
    StarkBank.CorporateHolder.Log.query(limit: 10)
      |> Enum.take(10)
      |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :corporate_holder_log
  test "query! corporate holder log" do
    StarkBank.CorporateHolder.Log.query!(limit: 10)
      |> Enum.take(10)
      |> (fn list -> assert length(list) <= 10 end).()
  end

  @tag :corporate_holder_log
  test "page corporate holder log" do
      {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkBank.CorporateHolder.Log.page/1, 2, limit: 5)
      assert length(ids) <= 10
  end

  @tag :corporate_holder_log
  test "page! corporate holder log" do
      ids = StarkInfraTest.Utils.Page.get!(&StarkBank.CorporateHolder.Log.page!/1, 2, limit: 5)
      assert length(ids) <= 10
  end
end
