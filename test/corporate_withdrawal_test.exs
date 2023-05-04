defmodule StarkBankTest.CorporateWithdrawal do
  use ExUnit.Case

  @tag :corporate_withdrawal
  test "create corporate withdrawal test" do
    {:ok, corporate_withdrawal} = StarkBank.CorporateWithdrawal.create(example_corporate_withdrawal())
    {:ok, withdrawal} = StarkBank.CorporateWithdrawal.get(corporate_withdrawal.id)

    assert corporate_withdrawal.id == withdrawal.id
  end

  @tag :corporate_withdrawal
  test "create! corporate withdrawal test" do
    corporate_withdrawal = StarkBank.CorporateWithdrawal.create!(example_corporate_withdrawal())
    {:ok, withdrawal} = StarkBank.CorporateWithdrawal.get(corporate_withdrawal.id)

    assert corporate_withdrawal.id == withdrawal.id
  end

  @tag :corporate_withdrawal
  test "get corporate withdrawal test" do
    withdrawals = StarkBank.CorporateWithdrawal.query!(limit: 5)
    Enum.each(withdrawals, fn withdrawal ->
      {:ok, corporate_withdrawal} = StarkBank.CorporateWithdrawal.get(withdrawal.id)
      assert withdrawal.id == corporate_withdrawal.id
    end)
  end

  @tag :corporate_withdrawal
  test "get! corporate withdrawal test" do
    withdrawals = StarkBank.CorporateWithdrawal.query!(limit: 5)
    Enum.each(withdrawals, fn withdrawal ->
      corporate_withdrawal = StarkBank.CorporateWithdrawal.get!(withdrawal.id)
      assert withdrawal.id == corporate_withdrawal.id
    end)
  end

  @tag :corporate_withdrawal
  test "query corporate withdrawal test" do
    corporate_withdrawals = StarkBank.CorporateWithdrawal.query(limit: 10)
      |> Enum.take(10)

    Enum.each(corporate_withdrawals, fn withdrawal ->
      {:ok, withdrawal} = withdrawal
      assert withdrawal.id == StarkBank.CorporateWithdrawal.get!(withdrawal.id).id
    end)

    assert length(corporate_withdrawals) <= 10
  end

  @tag :corporate_withdrawal
  test "query! corporate withdrawal test" do
    corporate_withdrawals = StarkBank.CorporateWithdrawal.query!(limit: 10)
      |> Enum.take(10)

    Enum.each(corporate_withdrawals, fn withdrawal ->
      assert withdrawal.id == StarkBank.CorporateWithdrawal.get!(withdrawal.id).id
    end)

    assert length(corporate_withdrawals) <= 10
  end

  @tag :corporate_withdrawal
  test "page corporate withdrawal test" do
    {:ok, {_cursor, corporate_withdrawals}} = StarkBank.CorporateWithdrawal.page(limit: 10)

    assert length(corporate_withdrawals) <= 10

    Enum.each(corporate_withdrawals, fn withdrawal ->
      assert withdrawal.id == StarkBank.CorporateWithdrawal.get!(withdrawal.id).id
    end)
  end

  @tag :corporate_withdrawal
  test "page! corporate withdrawal test" do
    {_cursor, corporate_withdrawals} = StarkBank.CorporateWithdrawal.page!(limit: 10)

    assert length(corporate_withdrawals) <= 10

    Enum.each(corporate_withdrawals, fn withdrawal ->
      assert withdrawal.id == StarkBank.CorporateWithdrawal.get!(withdrawal.id).id
    end)
  end

  def example_corporate_withdrawal() do
    %StarkBank.CorporateWithdrawal{
      amount: 40,
      external_id: new_id()
    }
  end

  def new_id() do
    {_,_,diff} = :os.timestamp
    to_string(diff)
  end
end
