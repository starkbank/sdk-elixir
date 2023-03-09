defmodule StarkBankTest.BrcodePayment do
  use ExUnit.Case

  @tag :brcode_payment
  test "create brcode payment" do
    {:ok, payments} = StarkBank.BrcodePayment.create([example_payment()])
    payment = payments |> hd
    assert !is_nil(payment)
  end

  @tag :brcode_payment
  test "create! brcode payment" do
    payment = StarkBank.BrcodePayment.create!([example_payment()]) |> hd
    assert !is_nil(payment)
  end

  @tag :brcode_payment
  test "query brcode payment" do
    StarkBank.BrcodePayment.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :brcode_payment
  test "query! brcode payment" do
    StarkBank.BrcodePayment.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :brcode_payment
  test "page brcode payment" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.BrcodePayment.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :brcode_payment
  test "page! brcode payment" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.BrcodePayment.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :brcode_payment
  test "get brcode payment" do
    payment =
      StarkBank.BrcodePayment.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _payment} = StarkBank.BrcodePayment.get(payment.id)
  end

  @tag :brcode_payment
  test "get! brcode payment" do
    payment =
      StarkBank.BrcodePayment.query!()
      |> Enum.take(1)
      |> hd()

    _payment = StarkBank.BrcodePayment.get!(payment.id)
  end

  @tag :brcode_payment
  test "pdf brcode payment" do
    payment = StarkBank.BrcodePayment.query!(status: "success")
    |> Enum.take(1)
    |> hd()

    {:ok, _pdf} = StarkBank.BrcodePayment.pdf(payment.id)
  end

  @tag :brcode_payment
  test "pdf! brcode payment" do
    payment = StarkBank.BrcodePayment.query!(status: "success")
    |> Enum.take(1)
    |> hd()

    pdf = StarkBank.BrcodePayment.pdf!(payment.id)
    file = File.open!("tmp/brcode-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  def example_payment(push_schedule \\ false)

  def example_payment(push_schedule) when push_schedule do
    %{example_payment(false) | scheduled: Date.utc_today() |> Date.add(1)}
  end

  def example_payment(_push_schedule) do
    invoice = StarkBank.Invoice.create!([StarkBankTest.Invoice.example_invoice()]) |> hd

    %StarkBank.BrcodePayment{
      brcode: invoice.brcode,
      description: "loading a random account",
      tax_id: invoice.tax_id,
      rules: [
        %StarkBank. BrcodePayment.Rule{
          key: "resendingLimit",
          value: 5
        }
      ]
    }
  end
end
