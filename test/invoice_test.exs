defmodule StarkBankTest.Invoice do

  use ExUnit.Case

  @tag :invoice
  test "create invoice" do
    {:ok, invoices} = StarkBank.Invoice.create([example_invoice()])
    invoice = invoices |> hd
    assert !is_nil(invoice)

  end

  @tag :invoice
  test "create! invoice" do
    invoice = StarkBank.Invoice.create!([example_invoice()]) |> hd
    assert !is_nil(invoice)
  end

  @tag :invoice
  test "query invoice" do
    StarkBank.Invoice.query(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :invoice
  test "query! invoice" do
    StarkBank.Invoice.query!(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :invoice
  test "get invoice" do
    invoice =
      StarkBank.Invoice.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _invoice} = StarkBank.Invoice.get(invoice.id)
  end

  @tag :invoice
  test "get! invoice" do
    invoice =
      StarkBank.Invoice.query!()
      |> Enum.take(1)
      |> hd()

    _invoice = StarkBank.Invoice.get!(invoice.id)
  end

  @tag :invoice
  test "update invoice status" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    {:ok, updated_invoice} = StarkBank.Invoice.update(invoice.id, status: "canceled")
    assert updated_invoice.status == "canceled"
  end

  @tag :invoice
  test "update! invoice status" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    updated_invoice = StarkBank.Invoice.update!(invoice.id, status: "canceled")
    assert updated_invoice.status == "canceled"
  end

  @tag :invoice
  test "update invoice amount" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    {:ok, updated_invoice} = StarkBank.Invoice.update(invoice.id, amount: 123456)
    assert updated_invoice.amount == 123456
  end

  @tag :invoice
  test "update! invoice amount" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    updated_invoice = StarkBank.Invoice.update!(invoice.id, amount: 123456)
    assert updated_invoice.amount == 123456
  end

  @tag :invoice
  test "update invoice due" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    datetime = get_future_datetime(5)
    {:ok, updated_invoice} = StarkBank.Invoice.update(invoice.id, due: datetime)
    assert updated_invoice.due == datetime
  end

  @tag :invoice
  test "update! invoice due" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    datetime = get_future_datetime(5)
    updated_invoice = StarkBank.Invoice.update!(invoice.id, due: datetime)
    assert updated_invoice.due == datetime
  end

  @tag :invoice
  test "update invoice expiration" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    {:ok, updated_invoice} = StarkBank.Invoice.update(invoice.id, expiration: 123456)
    assert updated_invoice.expiration == 123456
  end

  @tag :invoice
  test "update! invoice expiration" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    updated_invoice = StarkBank.Invoice.update!(invoice.id, expiration: 123456)
    assert updated_invoice.expiration == 123456
  end

  def example_invoice() do
    %StarkBank.Invoice{
      amount: 400000,
      due: get_future_datetime(30),
      tax_id: "012.345.678-90",
      name: "Iron Bank S.A.",

      expiration: 123456789,
      fine: 2.5,
      interest: 1.3,
      discounts: [
          %{
              percentage: 10,
              due: get_future_datetime(20)
          }
      ],
      tags: [
              "War supply",
              "Invoice #1234"
      ],
      descriptions: [
          %{
              key: "Field1",
              value: "Something"
          }
      ]
    }
  end

  def get_future_datetime(days) do
    datetime = DateTime.utc_now
    datetime = DateTime.add(datetime, days*24*60*60, :second)
    datetime = DateTime.to_iso8601(datetime)
    String.replace(datetime, "Z", "+00:00")
  end
end
