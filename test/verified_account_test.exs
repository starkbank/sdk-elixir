defmodule StarkBankTest.VerifiedAccount do
  use ExUnit.Case

  @tag :verified_account
  test "create verified_account" do
    {:ok, accounts} = StarkBank.VerifiedAccount.create([example_verified_account()])
    account = accounts |> hd
    assert !is_nil(account)
  end

  @tag :verified_account
  test "create! verified_account" do
    account = StarkBank.VerifiedAccount.create!([example_verified_account()]) |> hd
    assert !is_nil(account)
  end

  @tag :verified_account
  test "query verified_account" do
    StarkBank.VerifiedAccount.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :verified_account
  test "query! verified_account" do
    StarkBank.VerifiedAccount.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :verified_account
  test "page verified_account" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.VerifiedAccount.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :verified_account
  test "page! verified_account" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.VerifiedAccount.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :verified_account
  test "get verified_account" do
    account =
      StarkBank.VerifiedAccount.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _account} = StarkBank.VerifiedAccount.get(account.id)
  end

  @tag :verified_account
  test "get! verified_account" do
    account =
      StarkBank.VerifiedAccount.query!()
      |> Enum.take(1)
      |> hd()

    _account = StarkBank.VerifiedAccount.get!(account.id)
  end

  @tag :verified_account
  test "cancel and cancel! verified_account" do
    {:ok, [first, second]} =
      StarkBank.VerifiedAccount.create([example_verified_account(), example_verified_account()])

    {:ok, canceled_account} = StarkBank.VerifiedAccount.cancel(first.id)
    assert canceled_account.status == "canceled"

    canceled_account! = StarkBank.VerifiedAccount.cancel!(second.id)
    assert canceled_account!.status == "canceled"
  end

  def example_verified_account() do
    %StarkBank.VerifiedAccount{
      tax_id: "01234567890",
      bank_code: "20018183",
      branch_code: "0001",
      name: "João",
      number:
        :rand.uniform(99999)
        |> to_string
        |> String.pad_leading(5, "0")
        |> (fn s -> s <> "-#{:rand.uniform(9)}" end).(),
      type: "checking",
      tags: ["employees", "monthly"]
    }
  end
end
