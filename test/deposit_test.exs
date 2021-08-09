defmodule StarkBankTest.Deposit do
  use ExUnit.Case

  @tag :deposit
  test "query deposit" do
    StarkBank.Deposit.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :deposit
  test "query! deposit" do
    StarkBank.Deposit.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :deposit
  test "query deposit ids" do
    deposits_ids_expected =
      StarkBank.Deposit.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, deposit} -> deposit.id end)

    assert length(deposits_ids_expected) <= 10

    deposits_ids_result =
      StarkBank.Deposit.query(ids: deposits_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, deposit} -> deposit.id end)

    assert length(deposits_ids_result) <= 10

    deposits_ids_expected = Enum.sort(deposits_ids_expected)
    deposits_ids_result = Enum.sort(deposits_ids_result)

    assert deposits_ids_expected == deposits_ids_result
  end

  @tag :deposit
  test "query! deposit ids" do
    deposits_ids_expected =
      StarkBank.Deposit.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn deposit -> deposit.id end)

    assert length(deposits_ids_expected) <= 10

    deposits_ids_result =
      StarkBank.Deposit.query!(ids: deposits_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn deposit -> deposit.id end)

    assert length(deposits_ids_result) <= 10

    deposits_ids_expected = Enum.sort(deposits_ids_expected)
    deposits_ids_result = Enum.sort(deposits_ids_result)

    assert deposits_ids_expected == deposits_ids_result
  end

  @tag :deposit
  test "page deposit" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Deposit.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :deposit
  test "page! deposit" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Deposit.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :deposit
  test "get deposit" do
    deposit =
      StarkBank.Deposit.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _deposit} = StarkBank.Deposit.get(deposit.id)
  end

  @tag :deposit
  test "get! deposit" do
    deposit =
      StarkBank.Deposit.query!()
      |> Enum.take(1)
      |> hd()

    _deposit = StarkBank.Deposit.get!(deposit.id)
  end
end
