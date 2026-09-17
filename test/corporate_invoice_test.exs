defmodule StarkBankTest.CorporateInvoice do
  use ExUnit.Case

  @tag :corporate_invoice
  test "create corporate_invoice" do
    {:ok, invoice} = StarkBank.CorporateInvoice.create(example_corporate_invoice())
    assert !is_nil(invoice)
  end

  @tag :corporate_invoice
  test "create! corporate_invoice" do
    invoice = StarkBank.CorporateInvoice.create!(example_corporate_invoice())
    assert !is_nil(invoice)
  end

  @tag :corporate_invoice
  test "query corporate_invoice" do
    StarkBank.CorporateInvoice.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :corporate_invoice
  test "query! corporate_invoice" do
    StarkBank.CorporateInvoice.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :corporate_invoice
  test "page corporate_invoice" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateInvoice.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_invoice
  test "page! corporate_invoice" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateInvoice.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  def example_corporate_invoice() do
    %StarkBank.CorporateInvoice{
      amount: :rand.uniform(100_000),
      tags: ["Traveler Employee"]
    }
  end
end
