defmodule StarkBankTest.BoletoPayment do
  use ExUnit.Case

  @tag :exclude
  test "create boleto payment" do
    user = StarkBankTest.Credentials.project()
    {:ok, boletos} = StarkBank.Payment.Boleto.create(user, [example_payment()])
    boleto = boletos |> hd
    assert !is_nil(boleto)
  end

  @tag :exclude
  test "create! boleto payment" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Payment.Boleto.create!(user, [example_payment()]) |> hd
    assert !is_nil(boleto)
  end

  @tag :exclude
  test "query boleto payment" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Boleto.query(user, limit: 101)
     |> Enum.take(101)
     |> (fn list -> assert length(list) == 101 end).()
  end

  @tag :exclude
  test "query! boleto payment" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Boleto.query!(user, limit: 101)
     |> Enum.take(101)
     |> (fn list -> assert length(list) == 101 end).()
  end

  @tag :exclude
  test "get boleto payment" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Payment.Boleto.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _boleto} = StarkBank.Payment.Boleto.get(user, boleto.id)
  end

  @tag :exclude
  test "get! boleto payment" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Payment.Boleto.query!(user)
     |> Enum.take(1)
     |> hd()
    _boleto = StarkBank.Payment.Boleto.get!(user, boleto.id)
  end

  @tag :exclude
  test "pdf boleto payment" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Payment.Boleto.query!(user, status: "success")
     |> Enum.take(1)
     |> hd()
    {:ok, _pdf} = StarkBank.Payment.Boleto.pdf(user, boleto.id)
  end

  @tag :exclude
  test "pdf! boleto payment" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Payment.Boleto.query!(user, status: "success")
     |> Enum.take(1)
     |> hd()
    pdf = StarkBank.Payment.Boleto.pdf!(user, boleto.id)
    file = File.open!("boleto-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :exclude
  test "delete boleto payment" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Payment.Boleto.create!(user, [example_payment()]) |> hd
    {:ok, deleted_boleto} = StarkBank.Payment.Boleto.delete(user, boleto.id)
    assert !is_nil(deleted_boleto)
  end

  @tag :exclude
  test "delete! boleto payment" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Payment.Boleto.create!(user, [example_payment()]) |> hd
    deleted_boleto = StarkBank.Payment.Boleto.delete!(user, boleto.id)
    assert !is_nil(deleted_boleto)
  end

  defp example_payment() do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.create!(user, [StarkBankTest.Boleto.example_boleto()]) |> hd
    %StarkBank.Payment.Boleto.Data{
      line: boleto.line,
      scheduled: Date.utc_today() |> Date.add(1),
      description: "loading a random account",
      tax_id: boleto.tax_id
    }
  end
end
