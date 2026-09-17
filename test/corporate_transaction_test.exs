defmodule StarkBankTest.CorporateTransaction do
  use ExUnit.Case

  @tag :corporate_transaction
  test "query corporate_transaction" do
    StarkBank.CorporateTransaction.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_transaction
  test "query! corporate_transaction" do
    StarkBank.CorporateTransaction.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_transaction
  test "query corporate_transaction ids" do
    transactions_ids_expected =
      StarkBank.CorporateTransaction.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, transaction} -> transaction.id end)

    assert length(transactions_ids_expected) <= 10

    transactions_ids_result =
      StarkBank.CorporateTransaction.query(ids: transactions_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, transaction} -> transaction.id end)

    assert length(transactions_ids_result) <= 10

    transactions_ids_expected = Enum.sort(transactions_ids_expected)
    transactions_ids_result = Enum.sort(transactions_ids_result)

    assert transactions_ids_expected == transactions_ids_result
  end

  @tag :corporate_transaction
  test "query! corporate_transaction ids" do
    transactions_ids_expected =
      StarkBank.CorporateTransaction.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn transaction -> transaction.id end)

    assert length(transactions_ids_expected) <= 10

    transactions_ids_result =
      StarkBank.CorporateTransaction.query!(ids: transactions_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn transaction -> transaction.id end)

    assert length(transactions_ids_result) <= 10

    transactions_ids_expected = Enum.sort(transactions_ids_expected)
    transactions_ids_result = Enum.sort(transactions_ids_result)

    assert transactions_ids_expected == transactions_ids_result
  end

  @tag :corporate_transaction
  test "page corporate_transaction" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateTransaction.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_transaction
  test "page! corporate_transaction" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateTransaction.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_transaction
  test "get corporate_transaction" do
    transaction =
      StarkBank.CorporateTransaction.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _transaction} = StarkBank.CorporateTransaction.get(transaction.id)
  end

  @tag :corporate_transaction
  test "get! corporate_transaction" do
    transaction =
      StarkBank.CorporateTransaction.query!()
      |> Enum.take(1)
      |> hd()

    _transaction = StarkBank.CorporateTransaction.get!(transaction.id)
  end
end
