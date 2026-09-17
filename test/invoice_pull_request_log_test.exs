defmodule StarkBankTest.InvoicePullRequestLog do
  use ExUnit.Case

  @tag :invoice_pull_request_log
  test "query invoice_pull_request_log" do
    StarkBank.InvoicePullRequest.Log.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :invoice_pull_request_log
  test "query! invoice_pull_request_log" do
    StarkBank.InvoicePullRequest.Log.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :invoice_pull_request_log
  test "get invoice_pull_request_log" do
    log =
      StarkBank.InvoicePullRequest.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.InvoicePullRequest.Log.get(log.id)
    assert get_log.id == log.id
    assert !is_nil(get_log.type)
    assert %StarkBank.InvoicePullRequest{} = get_log.request
    assert !is_nil(get_log.request.id)
    assert is_list(get_log.errors)

    Enum.each(get_log.errors, fn error ->
      assert %StarkBank.Error{} = error
    end)
  end

  @tag :invoice_pull_request_log
  test "get! invoice_pull_request_log" do
    log =
      StarkBank.InvoicePullRequest.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.InvoicePullRequest.Log.get!(log.id)
    assert get_log.id == log.id
    assert %StarkBank.InvoicePullRequest{} = get_log.request
  end

  @tag :invoice_pull_request_log
  test "page invoice_pull_request_log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.InvoicePullRequest.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :invoice_pull_request_log
  test "page! invoice_pull_request_log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.InvoicePullRequest.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
end
