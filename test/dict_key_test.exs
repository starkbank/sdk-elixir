defmodule StarkBankTest.DictKey do
  use ExUnit.Case

  @tag :dict_key
  test "get! dict_key" do
    pix_key = "tony@starkbank.com"
    dict_key = StarkBank.DictKey.get!(pix_key)
    assert !is_nil(dict_key.id)
    assert dict_key.id == pix_key
  end

  @tag :dict_key
  test "get dict_key" do
    pix_key = "tony@starkbank.com"
    {:ok, dict_key} = StarkBank.DictKey.get(pix_key)
    assert !is_nil(dict_key.id)
    assert dict_key.id == pix_key
  end

  @tag :dict_key
  test "query dict_key" do
    StarkBank.DictKey.query(limit: 1, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :dict_key
  test "query! dict_key" do
    StarkBank.DictKey.query!(limit: 1, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 1 end).()
  end
end
