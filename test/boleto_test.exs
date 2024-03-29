defmodule StarkBankTest.Boleto do
  use ExUnit.Case

  @tag :boleto
  test "create boleto" do
    {:ok, boletos} = StarkBank.Boleto.create([example_boleto()])
    boleto = boletos |> hd
    assert !is_nil(boleto)
  end

  @tag :boleto
  test "create! boleto" do
    boleto = StarkBank.Boleto.create!([example_boleto()]) |> hd
    assert !is_nil(boleto)
  end

  @tag :boleto
  test "query boleto" do
    StarkBank.Boleto.query(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto
  test "query! boleto" do
    StarkBank.Boleto.query!(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto
  test "page boleto" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Boleto.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :boleto
  test "page! boleto" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Boleto.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :boleto
  test "get boleto" do
    boleto =
      StarkBank.Boleto.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _boleto} = StarkBank.Boleto.get(boleto.id)
  end

  @tag :boleto
  test "get! boleto" do
    boleto =
      StarkBank.Boleto.query!()
      |> Enum.take(1)
      |> hd()

    _boleto = StarkBank.Boleto.get!(boleto.id)
  end

  @tag :boleto
  test "pdf boleto" do
    boleto =
      StarkBank.Boleto.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _pdf} = StarkBank.Boleto.pdf(boleto.id, layout: "default")
  end

  @tag :boleto
  test "pdf! boleto" do
    boleto =
      StarkBank.Boleto.query!()
      |> Enum.take(1)
      |> hd()

    pdf = StarkBank.Boleto.pdf!(boleto.id, layout: "booklet")
    file = File.open!("tmp/boleto.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :boleto
  test "delete boleto" do
    boleto = StarkBank.Boleto.create!([example_boleto()]) |> hd
    {:ok, deleted_boleto} = StarkBank.Boleto.delete(boleto.id)
    assert !is_nil(deleted_boleto)
  end

  @tag :boleto
  test "delete! boleto" do
    boleto = StarkBank.Boleto.create!([example_boleto()]) |> hd
    deleted_boleto = StarkBank.Boleto.delete!(boleto.id)
    assert !is_nil(deleted_boleto)
  end

  def example_boleto() do
    %StarkBank.Boleto{
      amount: 200,
      due: Date.utc_today() |> Date.add(8),
      name: "Random Company",
      street_line_1: "Rua ABC",
      street_line_2: "Ap 123",
      district: "Jardim Paulista",
      city: "São Paulo",
      state_code: "SP",
      zip_code: "01234-567",
      tax_id: "012.345.678-90",
      receiver_name: "Random Receiver",
      receiver_tax_id: "123.456.789-09",
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
      ],
      discounts: [
        %{
          percentage: 5,
          date: Date.utc_today()
        },
        %{
          percentage: 1.5,
          date: Date.utc_today() |> Date.add(2)
        }
      ]
    }
  end
end
