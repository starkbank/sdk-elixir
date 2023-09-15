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
  test "page invoice" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Invoice.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :invoice
  test "page! invoice" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Invoice.page!/1, 2, limit: 5)
    assert length(ids) == 10
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
  test "get payment" do
    invoice =
      StarkBank.Invoice.query!(status: "paid")
      |> Enum.take(1)
      |> hd()
    {:ok, payment} = StarkBank.Invoice.payment(invoice.id)
    assert !is_nil(payment)
  end

  @tag :invoice
  test "get payment!" do
    invoice =
      StarkBank.Invoice.query!(status: "paid")
      |> Enum.take(1)
      |> hd()
    payment = StarkBank.Invoice.payment!(invoice.id)
    assert !is_nil(payment)
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
  test "update invoice due, amount, expiration" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    datetime = get_future_datetime(5)
    {:ok, updated_invoice} = StarkBank.Invoice.update(invoice.id, due: datetime, amount: 123456, expiration: 123456)
    assert updated_invoice.due == datetime
    assert updated_invoice.amount == 123456
    assert updated_invoice.expiration == 123456
  end

  @tag :invoice
  test "update! invoice due, amount, expiration" do
    invoice =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    datetime = get_future_datetime(5)
    updated_invoice = StarkBank.Invoice.update!(invoice.id, due: datetime, amount: 123456, expiration: 123456)
    assert updated_invoice.due == datetime
    assert updated_invoice.amount == 123456
    assert updated_invoice.expiration == 123456
  end

  @tag :invoice
  test "qrcode invoice" do
    payment =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    {:ok, _qrcode} = StarkBank.Invoice.qrcode(payment.id)
  end

  @tag :invoice
  test "qrcode! invoice" do
    payment =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    qrcode = StarkBank.Invoice.qrcode!(payment.id)
    file = File.open!("tmp/invoice_qrcode.png", [:write])
    IO.binwrite(file, qrcode)
    File.close(file)
  end

  @tag :invoice
  test "pdf invoice" do
    payment =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    {:ok, _pdf} = StarkBank.Invoice.pdf(payment.id)
  end

  @tag :invoice
  test "pdf! invoice" do
    payment =
      StarkBank.Invoice.query!(status: "created")
      |> Enum.take(1)
      |> hd()

    pdf = StarkBank.Invoice.pdf!(payment.id)
    file = File.open!("tmp/invoice.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
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
    DateTime.add(datetime, days*24*60*60, :second)
  end
end
