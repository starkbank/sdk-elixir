defmodule StarkBankTest.VerifiedAccountLog do
  use ExUnit.Case

  @tag :verified_account_log
  test "query verified_account_log" do
    StarkBank.VerifiedAccount.Log.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :verified_account_log
  test "query! verified_account_log" do
    StarkBank.VerifiedAccount.Log.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :verified_account_log
  test "get verified_account_log" do
    log =
      StarkBank.VerifiedAccount.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.VerifiedAccount.Log.get(log.id)
    assert get_log.id == log.id
    assert !is_nil(get_log.type)
    assert %StarkBank.VerifiedAccount{} = get_log.account
    assert !is_nil(get_log.account.id)
    assert is_list(get_log.errors)

    Enum.each(get_log.errors, fn error ->
      assert %StarkBank.Error{} = error
    end)
  end

  @tag :verified_account_log
  test "get! verified_account_log" do
    log =
      StarkBank.VerifiedAccount.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.VerifiedAccount.Log.get!(log.id)
    assert get_log.id == log.id
    assert %StarkBank.VerifiedAccount{} = get_log.account
  end

  @tag :verified_account_log
  test "page verified_account_log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.VerifiedAccount.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :verified_account_log
  test "page! verified_account_log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.VerifiedAccount.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
end
