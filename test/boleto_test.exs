defmodule StarkBankTest.Boleto do
  use ExUnit.Case

  @tag :boleto
  test "create boleto" do
    user = StarkBankTest.Credentials.project()
    {:ok, boletos} = StarkBank.Boleto.create(user, [example_boleto()])
    boleto = boletos |> hd
    assert !is_nil(boleto)
  end

  @tag :boleto
  test "create! boleto" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.create!(user, [example_boleto()]) |> hd
    assert !is_nil(boleto)
  end

  @tag :boleto
  test "query boleto" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Boleto.query(user, limit: 101, before: DateTime.utc_now())
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto
  test "query! boleto" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Boleto.query!(user, limit: 101, before: DateTime.utc_now())
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto
  test "get boleto" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _boleto} = StarkBank.Boleto.get(user, boleto.id)
  end

  @tag :boleto
  test "get! boleto" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.query!(user)
     |> Enum.take(1)
     |> hd()
    _boleto = StarkBank.Boleto.get!(user, boleto.id)
  end

  @tag :boleto
  test "pdf boleto" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _pdf} = StarkBank.Boleto.pdf(user, boleto.id)
  end

  @tag :boleto
  test "pdf! boleto" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.query!(user)
     |> Enum.take(1)
     |> hd()
    pdf = StarkBank.Boleto.pdf!(user, boleto.id)
    file = File.open!("boleto.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :boleto
  test "delete boleto" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.create!(user, [example_boleto()]) |> hd
    {:ok, deleted_boleto} = StarkBank.Boleto.delete(user, boleto.id)
    assert !is_nil(deleted_boleto)
  end

  @tag :boleto
  test "delete! boleto" do
    user = StarkBankTest.Credentials.project()
    boleto = StarkBank.Boleto.create!(user, [example_boleto()]) |> hd
    deleted_boleto = StarkBank.Boleto.delete!(user, boleto.id)
    assert !is_nil(deleted_boleto)
  end

  def example_boleto() do
    %StarkBank.Boleto{
        amount: 200,
        due: Date.utc_today() |> Date.add(5),
        name: "Random Company",
        street_line_1: "Rua ABC",
        street_line_2: "Ap 123",
        district: "Jardim Paulista",
        city: "São Paulo",
        state_code: "SP",
        zip_code: "01234-567",
        tax_id: "012.345.678-90",
        overdue_limit: 10,
        fine: 0.00,
        interest: 0.00,
        descriptions: [
            %{
                text: "product A",
                amount: 123
            },
            %{
                text: "product B",
                amount: 456
            },
            %{
                text: "product C",
                amount: 789
            }
        ]
      }
  end
end
