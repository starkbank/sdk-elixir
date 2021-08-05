defmodule StarkBankTest.InvoiceLog do
  use ExUnit.Case

  @tag :invoice_log
  test "query invoice log" do
    StarkBank.Invoice.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :invoice_log
  test "query! invoice log" do
    StarkBank.Invoice.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :invoice_log
  test "query! invoice log with filters" do
    invoice = StarkBank.Invoice.query!(status: "paid")
    |> Enum.take(1)
    |> hd()

    StarkBank.Invoice.Log.query!(limit: 1, invoice_ids: [invoice.id], types: "paid")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :invoice_log
  test "get invoice log" do
    log =
      StarkBank.Invoice.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.Invoice.Log.get(log.id)
  end

  @tag :invoice_log
  test "get! invoice log" do
    log =
      StarkBank.Invoice.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.Invoice.Log.get!(log.id)
  end

  @tag :invoice_log
  test "pdf log" do
    payment =
      StarkBank.Invoice.Log.query!(types: "reversed")
      |> Enum.take(1)
      |> hd()

    {:ok, _pdf} = StarkBank.Invoice.Log.pdf(payment.id)
  end

  @tag :invoice_log
  test "pdf! log" do
    payment =
      StarkBank.Invoice.Log.query!(types: "reversed")
      |> Enum.take(1)
      |> hd()

    pdf = StarkBank.Invoice.Log.pdf!(payment.id)
    file = File.open!("tmp/invoice-log.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end
end
