defmodule StarkBankTest.SplitProfile do
  use ExUnit.Case

  @tag :split_profile
  test "put split_profile" do
    {:ok, [profile]} = StarkBank.SplitProfile.put([example_split_profile()])
    assert !is_nil(profile.id)
    assert !is_nil(profile.status)
  end

  @tag :split_profile
  test "put! split_profile" do
    [profile] = StarkBank.SplitProfile.put!([example_split_profile()])
    assert !is_nil(profile.id)
  end

  @tag :split_profile
  test "query split_profile" do
    StarkBank.SplitProfile.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_profile
  test "query! split_profile" do
    StarkBank.SplitProfile.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_profile
  test "page split_profile" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.SplitProfile.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split_profile
  test "page! split_profile" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.SplitProfile.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split_profile
  test "get split_profile" do
    profile =
      StarkBank.SplitProfile.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_profile} = StarkBank.SplitProfile.get(profile.id)
    assert get_profile.id == profile.id
  end

  @tag :split_profile
  test "get! split_profile" do
    profile =
      StarkBank.SplitProfile.query!()
      |> Enum.take(1)
      |> hd()

    get_profile = StarkBank.SplitProfile.get!(profile.id)
    assert get_profile.id == profile.id
  end

  def example_split_profile() do
    %StarkBank.SplitProfile{
      interval: "week",
      delay: 604_800,
      tags: ["Jaime", "Lannister"]
    }
  end
end
