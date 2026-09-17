defmodule StarkBankTest.MerchantCategory do
  use ExUnit.Case

  @tag :merchant_category
  test "query merchant_category" do
    StarkBank.MerchantCategory.query(search: "food")
    |> Enum.take(10)
    |> (fn list -> assert length(list) > 0 end).()
  end

  @tag :merchant_category
  test "query! merchant_category" do
    categories = StarkBank.MerchantCategory.query!(search: "food") |> Enum.take(10)
    assert length(categories) > 0

    assert Enum.all?(categories, fn category -> !is_nil(category.name) end)
  end
end
