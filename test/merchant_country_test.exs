defmodule StarkBankTest.MerchantCountry do
  use ExUnit.Case

  @tag :merchant_country
  test "query! merchant country test" do
    countries = StarkBank.MerchantCountry.query!(search: "brazil")
      |> Enum.take(1)
      |> hd

    assert !is_nil(countries.code)
  end

  @tag :merchant_country
  test "query merchant country test" do
    {:ok, countries} = StarkBank.MerchantCountry.query(search: "brazil")
      |> Enum.take(1)
      |> hd

    assert !is_nil(countries.code)
  end
end
