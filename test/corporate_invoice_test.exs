defmodule StarkBankTest.CorporateInvoice do
  use ExUnit.Case

  @tag :corporate_invoice
  test "create corporate invoice test" do
    {:ok, corporate_invoice} = StarkBank.CorporateInvoice.create(StarkInfraTest.Utils.CorporateInvoice.example_corporate_invoice())
    {:ok, invoice} = StarkBank.CorporateInvoice.get(corporate_invoice.id)

    assert corporate_invoice.id == invoice.id
  end

  @tag :corporate_invoice
  test "create! corporate invoice test" do
    corporate_invoice = StarkBank.CorporateInvoice.create!(StarkInfraTest.Utils.CorporateInvoice.example_corporate_invoice())
    {:ok, invoice} = StarkBank.CorporateInvoice.get(corporate_invoice.id)

    assert corporate_invoice.id == invoice.id
  end

  @tag :corporate_invoice
  test "get corporate invoice test" do
    invoices = StarkBank.CorporateInvoice.query!(limit: 5)
    Enum.each(invoices, fn invoice ->
      {:ok, corporate_invoice} = StarkBank.CorporateInvoice.get(invoice.id)
      assert invoice.id == corporate_invoice.id
    end)
  end

  @tag :corporate_invoice
  test "get! corporate invoice test" do
    invoices = StarkBank.CorporateInvoice.query!(limit: 5)
    Enum.each(invoices, fn invoice ->
      corporate_invoice = StarkBank.CorporateInvoice.get!(invoice.id)
      assert invoice.id == corporate_invoice.id
    end)
  end

  @tag :corporate_invoice
  test "query corporate invoice test" do
    corporate_invoices = StarkBank.CorporateInvoice.query(limit: 10)
      |> Enum.take(10)

    Enum.each(corporate_invoices, fn invoice ->
      {:ok, invoice} = invoice
      assert invoice.id == StarkBank.CorporateInvoice.get!(invoice.id).id
    end)

    assert length(corporate_invoices) <= 10
  end

  @tag :corporate_invoice
  test "query! corporate invoice test" do
    corporate_invoices = StarkBank.CorporateInvoice.query!(limit: 10)
      |> Enum.take(10)

    Enum.each(corporate_invoices, fn invoice ->
      assert invoice.id == StarkBank.CorporateInvoice.get!(invoice.id).id
    end)

    assert length(corporate_invoices) <= 10
  end

  @tag :corporate_invoice
  test "page corporate invoice test" do
    {:ok, ids} = StarkInfraTest.Utils.Page.get(&StarkBank.CorporateInvoice.page/1, 2, limit: 5)

    Enum.each(ids, fn id ->
      assert id == StarkBank.CorporateInvoice.get!(id).id
    end)

    assert length(ids) <= 10
  end

  @tag :corporate_invoice
  test "page! corporate invoice test" do
    ids = StarkInfraTest.Utils.Page.get!(&StarkBank.CorporateInvoice.page!/1, 2, limit: 5)

    Enum.each(ids, fn id ->
      assert id == StarkBank.CorporateInvoice.get!(id).id
    end)

    assert length(ids) <= 10
  end
end
