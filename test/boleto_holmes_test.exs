defmodule StarkBankTest.BoletoHolmes do
  use ExUnit.Case

  alias StarkBankTest.Boleto, as: BoletoTest

  @tag :boleto_holmes
  test "create boleto holmes" do
    {:ok, boletos} = StarkBank.Boleto.create([BoletoTest.example_boleto()])
    {:ok, holmes} = StarkBank.BoletoHolmes.create([example_boleto_holmes(boletos |> hd())])
    sherlock = holmes |> hd()
    assert !is_nil(sherlock)
  end

  @tag :boleto_holmes
  test "create! boleto holmes" do
    boletos = StarkBank.Boleto.create!([BoletoTest.example_boleto()])
    holmes = StarkBank.BoletoHolmes.create!([example_boleto_holmes(boletos |> hd())])
    sherlock = holmes |> hd()
    assert !is_nil(sherlock)
  end

  @tag :boleto_holmes
  test "query boleto holmes" do
    StarkBank.BoletoHolmes.query(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_holmes
  test "query! boleto holmes" do
    StarkBank.BoletoHolmes.query!(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
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
end
