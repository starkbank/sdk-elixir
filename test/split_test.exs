defmodule StarkBankTest.Split do
  use ExUnit.Case

  # Splits are created by the parent Invoice/Boleto payment, never directly
  # by the user, so there is no create test here - only get/query/page.

  @tag :split
  test "query split" do
    StarkBank.Split.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split
  test "query! split" do
    StarkBank.Split.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split
  test "page split" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Split.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split
  test "page! split" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Split.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split
  test "get split" do
    split =
      StarkBank.Split.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_split} = StarkBank.Split.get(split.id)
    assert get_split.id == split.id
  end

  @tag :split
  test "get! split" do
    split =
      StarkBank.Split.query!()
      |> Enum.take(1)
      |> hd()

    get_split = StarkBank.Split.get!(split.id)
    assert get_split.id == split.id
  end
end
