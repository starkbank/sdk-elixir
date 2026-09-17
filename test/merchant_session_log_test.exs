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

    {:ok, _log} = StarkBank.MerchantSession.Log.get(log.id)
  end

  @tag :merchant_session_log
  test "get! merchant_session_log" do
    log =
      StarkBank.MerchantSession.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.MerchantSession.Log.get!(log.id)
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
