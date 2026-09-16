defmodule StarkBankTest.MerchantCountry do
  use ExUnit.Case

  @tag :merchant_country
  test "query merchant_country" do
    StarkBank.MerchantCountry.query(search: "brazil")
    |> Enum.take(10)
    |> (fn list -> assert length(list) > 0 end).()
  end

  @tag :merchant_country
  test "query! merchant_country" do
    countries = StarkBank.MerchantCountry.query!(search: "brazil") |> Enum.take(10)
    assert length(countries) > 0

    assert Enum.all?(countries, fn country -> !is_nil(country.code) end)
  end
end
