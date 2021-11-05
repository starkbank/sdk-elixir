defmodule StarkBankTest.Institution do
  use ExUnit.Case

  @tag :institution
  test "query institution" do
    {:ok, [_stark_name, _stark_scd_name]} = StarkBank.Institution.query(search: "stark")

    {:ok, [_stark_spi_code]} = StarkBank.Institution.query(spi_codes: "20018183")

    {:ok, [_itau_str_code]} = StarkBank.Institution.query(str_codes: "341")
  end

  @tag :institution
  test "query! institution" do
    assert length(StarkBank.Institution.query!(search: "stark")) == 2

    assert length(StarkBank.Institution.query!(spi_codes: "20018183")) == 1

    assert length(StarkBank.Institution.query!(str_codes: "341")) == 1
  end
end
