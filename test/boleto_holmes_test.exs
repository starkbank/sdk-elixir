defmodule StarkBank.Test.BoletoHolmes do
  use ExUnit.Case, async: true

  @tag :boleto_holmes
  test "create boleto holmes" do
    {:ok, boletos} = StarkBank.Boleto.create([example_boleto()])
    {:ok, holmes} = StarkBank.BoletoHolmes.create([example_boleto_holmes(boletos |> hd())])
    sherlock = holmes |> hd()
    assert !is_nil(sherlock)
  end

  @tag :boleto_holmes
  test "create! boleto holmes" do
    boletos = StarkBank.Boleto.create!([example_boleto()])
    holmes = StarkBank.BoletoHolmes.create!([example_boleto_holmes(boletos |> hd())])
    sherlock = holmes |> hd()
    assert !is_nil(sherlock)
  end

  @tag :boleto_holmes
  test "query boleto holmes" do
    StarkBank.BoletoHolmes.query(query: [limit: 101], before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_holmes
  test "query! boleto holmes" do
    StarkBank.BoletoHolmes.query!(query: [limit: 101], before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_holmes
  test "page boleto holmes" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.BoletoHolmes.page/1, 2, query: [limit: 1])
    assert length(ids) == 2
  end

  @tag :boleto_holmes
  test "page! boleto holmes" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.BoletoHolmes.page!/1, 2, query: [limit: 1])
    assert length(ids) == 2
  end

  @tag :boleto_holmes
  test "get boleto holmes" do
    sherlock =
      StarkBank.BoletoHolmes.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _sherlock} = StarkBank.BoletoHolmes.get(sherlock.id)
  end

  @tag :boleto_holmes
  test "get! boleto holmes" do
    sherlock =
      StarkBank.BoletoHolmes.query!()
      |> Enum.take(1)
      |> hd()

    _sherlock = StarkBank.BoletoHolmes.get!(sherlock.id)
  end

  def example_boleto_holmes(boleto) do
    %StarkBank.BoletoHolmes{
      boleto_id: boleto.id,
      tags: ["sherlock", "holmes"],
    }
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
