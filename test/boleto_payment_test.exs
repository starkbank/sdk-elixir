defmodule StarkBankTest.BoletoPayment do
  use ExUnit.Case

  @tag :boleto_payment
  test "create boleto payment" do
    {:ok, payments} = StarkBank.BoletoPayment.create([example_payment()])
    payment = payments |> hd
    assert !is_nil(payment)
  end

  @tag :boleto_payment
  test "create! boleto payment" do
    payment = StarkBank.BoletoPayment.create!([example_payment()]) |> hd
    assert !is_nil(payment)
  end

  @tag :boleto_payment
  test "query boleto payment" do
    StarkBank.BoletoPayment.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_payment
  test "query! boleto payment" do
    StarkBank.BoletoPayment.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_payment
  test "get boleto payment" do
    payment =
      StarkBank.BoletoPayment.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _payment} = StarkBank.BoletoPayment.get(payment.id)
  end

  @tag :boleto_payment
  test "get! boleto payment" do
    payment =
      StarkBank.BoletoPayment.query!()
      |> Enum.take(1)
      |> hd()

    _payment = StarkBank.BoletoPayment.get!(payment.id)
  end

  @tag :boleto_payment
  test "pdf boleto payment" do
    payment =
      StarkBank.BoletoPayment.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    {:ok, _pdf} = StarkBank.BoletoPayment.pdf(payment.id)
  end

  @tag :boleto_payment
  test "pdf! boleto payment" do
    payment =
      StarkBank.BoletoPayment.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    pdf = StarkBank.BoletoPayment.pdf!(payment.id)
    file = File.open!("tmp/boleto-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :boleto_payment
  test "delete boleto payment" do
    payment = StarkBank.BoletoPayment.create!([example_payment()]) |> hd
    {:ok, deleted_payment} = StarkBank.BoletoPayment.delete(payment.id)
    assert !is_nil(deleted_payment)
  end

  @tag :boleto_payment
  test "delete! boleto payment" do
    payment = StarkBank.BoletoPayment.create!([example_payment()]) |> hd
    deleted_payment = StarkBank.BoletoPayment.delete!(payment.id)
    assert !is_nil(deleted_payment)
  end

  def example_payment(push_schedule \\ false)

  def example_payment(push_schedule) when push_schedule do
    %{example_payment(false) | scheduled: Date.utc_today() |> Date.add(1)}
  end

  def example_payment(_push_schedule) do
    boleto = StarkBank.Boleto.create!([StarkBankTest.Boleto.example_boleto()]) |> hd

    %StarkBank.BoletoPayment{
      line: boleto.line,
      description: "loading a random account",
      tax_id: boleto.tax_id
    }
  end
end
