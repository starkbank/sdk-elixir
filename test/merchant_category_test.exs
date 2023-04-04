defmodule StarkBankTest.MerchantCategory do
  use ExUnit.Case

  @tag :merchant_category
  test "query! merchant category test" do
    categories = StarkBank.MerchantCategory.query!(search: "food")
      |> Enum.take(1)
      |> hd

    assert !is_nil(categories.code)
  end

  @tag :merchant_category
  test "query merchant category test" do
    {:ok, categories} = StarkBank.MerchantCategory.query(search: "food")
      |> Enum.take(1)
      |> hd

    assert !is_nil(categories.code)
  end
end
