defmodule StarkBankTest.CorporateHolderLog do
  use ExUnit.Case

  @tag :corporate_holder_log
  test "query corporate_holder log" do
    StarkBank.CorporateHolder.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_holder_log
  test "query! corporate_holder log" do
    StarkBank.CorporateHolder.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_holder_log
  test "query! corporate_holder log with filters" do
    holder =
      StarkBank.CorporateHolder.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.CorporateHolder.Log.query!(limit: 1, holder_ids: [holder.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :corporate_holder_log
  test "page corporate_holder log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateHolder.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_holder_log
  test "page! corporate_holder log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateHolder.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_holder_log
  test "get corporate_holder log" do
    log =
      StarkBank.CorporateHolder.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.CorporateHolder.Log.get(log.id)
  end

  @tag :corporate_holder_log
  test "get! corporate_holder log" do
    log =
      StarkBank.CorporateHolder.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.CorporateHolder.Log.get!(log.id)
  end
end
