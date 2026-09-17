defmodule StarkBankTest.SplitProfileLog do
  use ExUnit.Case

  @tag :split_profile_log
  test "query split_profile_log" do
    StarkBank.SplitProfile.Log.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_profile_log
  test "query! split_profile_log" do
    StarkBank.SplitProfile.Log.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_profile_log
  test "get split_profile_log" do
    log =
      StarkBank.SplitProfile.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.SplitProfile.Log.get(log.id)
    assert get_log.id == log.id
    assert !is_nil(get_log.type)
    assert %StarkBank.SplitProfile{} = get_log.profile
    assert !is_nil(get_log.profile.id)
    assert is_list(get_log.errors)

    Enum.each(get_log.errors, fn error ->
      assert %StarkBank.Error{} = error
    end)
  end

  @tag :split_profile_log
  test "get! split_profile_log" do
    log =
      StarkBank.SplitProfile.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.SplitProfile.Log.get!(log.id)
    assert get_log.id == log.id
    assert %StarkBank.SplitProfile{} = get_log.profile
  end

  @tag :split_profile_log
  test "page split_profile_log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.SplitProfile.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split_profile_log
  test "page! split_profile_log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.SplitProfile.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
end
