defmodule StarkBankTest.MerchantSessionLog do
  use ExUnit.Case

  @tag :merchant_session_log
  test "query merchant_session_log" do
    StarkBank.MerchantSession.Log.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :merchant_session_log
  test "query! merchant_session_log" do
    StarkBank.MerchantSession.Log.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :merchant_session_log
  test "get merchant_session_log" do
    log =
      StarkBank.MerchantSession.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.MerchantSession.Log.get(log.id)
    assert get_log.id == log.id
    assert !is_nil(get_log.type)
    # exercita o parse do sub-objeto e o de errors
    assert %StarkBank.MerchantSession{} = get_log.session
    assert !is_nil(get_log.session.id)
    assert is_list(get_log.errors)

    Enum.each(get_log.errors, fn error ->
      assert %StarkBank.Error{} = error
    end)
  end

  @tag :merchant_session_log
  test "get! merchant_session_log" do
    log =
      StarkBank.MerchantSession.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.MerchantSession.Log.get!(log.id)
    assert get_log.id == log.id
    assert %StarkBank.MerchantSession{} = get_log.session
  end

  @tag :merchant_session_log
  test "page merchant_session_log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.MerchantSession.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_session_log
  test "page! merchant_session_log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.MerchantSession.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
end
