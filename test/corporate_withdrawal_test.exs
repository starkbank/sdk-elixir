defmodule StarkBankTest.CorporateWithdrawal do
  use ExUnit.Case

  @tag :corporate_withdrawal
  test "create corporate_withdrawal" do
    {:ok, withdrawal} = StarkBank.CorporateWithdrawal.create(example_corporate_withdrawal())
    assert !is_nil(withdrawal)
  end

  @tag :corporate_withdrawal
  test "create! corporate_withdrawal" do
    withdrawal = StarkBank.CorporateWithdrawal.create!(example_corporate_withdrawal())
    assert !is_nil(withdrawal)
  end

  @tag :corporate_withdrawal
  test "query corporate_withdrawal" do
    StarkBank.CorporateWithdrawal.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :corporate_withdrawal
  test "query! corporate_withdrawal" do
    StarkBank.CorporateWithdrawal.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :corporate_withdrawal
  test "page corporate_withdrawal" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateWithdrawal.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_withdrawal
  test "page! corporate_withdrawal" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateWithdrawal.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_withdrawal
  test "get corporate_withdrawal" do
    withdrawal = StarkBank.CorporateWithdrawal.create!(example_corporate_withdrawal())
    {:ok, _withdrawal} = StarkBank.CorporateWithdrawal.get(withdrawal.id)
  end

  @tag :corporate_withdrawal
  test "get! corporate_withdrawal" do
    withdrawal = StarkBank.CorporateWithdrawal.create!(example_corporate_withdrawal())
    _withdrawal = StarkBank.CorporateWithdrawal.get!(withdrawal.id)
  end

  def example_corporate_withdrawal() do
    %StarkBank.CorporateWithdrawal{
      amount: :rand.uniform(100_000),
      external_id: "#{:rand.uniform(1_000_000)}",
      tags: ["Traveler Employee"]
    }
  end
end
