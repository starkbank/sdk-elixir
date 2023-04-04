defmodule StarkBankTest.CorporateTransaction do
  use ExUnit.Case

  @tag :corporate_transaction
  test "query corporate transaction test" do
    corporate_transactions = StarkBank.CorporateTransaction.query(limit: 10)
      |> Enum.take(10)

    Enum.each(corporate_transactions, fn transaction ->
      {:ok, transaction} = transaction
      assert transaction.id == StarkBank.CorporateTransaction.get!(transaction.id).id
    end)

    assert length(corporate_transactions) <= 10
  end

  @tag :corporate_transaction
  test "query! corporate transaction test" do
    corporate_transactions = StarkBank.CorporateTransaction.query!(limit: 10)
      |> Enum.take(10)

    Enum.each(corporate_transactions, fn transaction ->
      assert transaction.id == StarkBank.CorporateTransaction.get!(transaction.id).id
    end)

    assert length(corporate_transactions) <= 10
  end

  @tag :corporate_transaction
  test "page corporate transaction test" do
    {:ok, {_cursor, corporate_transactions}} = StarkBank.CorporateTransaction.page(limit: 10)

    Enum.each(corporate_transactions, fn transaction ->
      assert transaction.id == StarkBank.CorporateTransaction.get!(transaction.id).id
    end)

    assert length(corporate_transactions) <= 10
  end

  @tag :corporate_transaction
  test "page! corporate transaction test" do
    {_cursor, corporate_transactions} = StarkBank.CorporateTransaction.page!(limit: 10)

    Enum.each(corporate_transactions, fn transaction ->
      assert transaction.id == StarkBank.CorporateTransaction.get!(transaction.id).id
    end)

    assert length(corporate_transactions) <= 10
  end
end
