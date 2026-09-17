defmodule StarkBankTest.SplitLog do
  use ExUnit.Case

  @tag :split_log
  test "query split_log" do
    StarkBank.Split.Log.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_log
  test "query! split_log" do
    StarkBank.Split.Log.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_log
  test "get split_log" do
    log =
      StarkBank.Split.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.Split.Log.get(log.id)
    assert get_log.id == log.id
    assert !is_nil(get_log.type)
    assert %StarkBank.Split{} = get_log.split
    assert !is_nil(get_log.split.id)
    assert is_list(get_log.errors)

    Enum.each(get_log.errors, fn error ->
      assert %StarkBank.Error{} = error
    end)
  end

  @tag :split_log
  test "get! split_log" do
    log =
      StarkBank.Split.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.Split.Log.get!(log.id)
    assert get_log.id == log.id
    assert %StarkBank.Split{} = get_log.split
  end

  @tag :split_log
  test "page split_log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Split.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split_log
  test "page! split_log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Split.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
end
