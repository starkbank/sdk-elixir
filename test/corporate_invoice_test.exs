defmodule StarkBankTest.CorporateInvoice do
  use ExUnit.Case

  @tag :corporate_invoice
  test "create corporate invoice test" do
    {:ok, corporate_invoice} = StarkBank.CorporateInvoice.create(example_corporate_invoice())

    assert !is_nil(corporate_invoice.id)
  end

  @tag :corporate_invoice
  test "create! corporate invoice test" do
    corporate_invoice = StarkBank.CorporateInvoice.create!(example_corporate_invoice())

    assert !is_nil(corporate_invoice.id)
  end

  @tag :corporate_invoice
  test "query corporate invoice test" do
    corporate_invoices = StarkBank.CorporateInvoice.query(limit: 10)
      |> Enum.take(10)

    assert length(corporate_invoices) <= 10
  end

  @tag :corporate_invoice
  test "query! corporate invoice test" do
    corporate_invoices = StarkBank.CorporateInvoice.query!(limit: 10)
      |> Enum.take(10)

    assert length(corporate_invoices) <= 10
  end

  @tag :corporate_invoice
  test "page corporate invoice test" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateInvoice.page/1, 2, limit: 5)

    assert length(ids) <= 10
  end

  @tag :corporate_invoice
  test "page! corporate invoice test" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateInvoice.page!/1, 2, limit: 5)

    assert length(ids) <= 10
  end

  def example_corporate_invoice() do
    %StarkBank.CorporateInvoice{
      amount: 2537
    }
  end
end
