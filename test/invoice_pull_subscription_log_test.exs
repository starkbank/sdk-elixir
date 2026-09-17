defmodule StarkBankTest.InvoicePullSubscriptionLog do
  use ExUnit.Case

  @tag :invoice_pull_subscription_log
  test "query invoice_pull_subscription_log" do
    StarkBank.InvoicePullSubscription.Log.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :invoice_pull_subscription_log
  test "query! invoice_pull_subscription_log" do
    StarkBank.InvoicePullSubscription.Log.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :invoice_pull_subscription_log
  test "get invoice_pull_subscription_log" do
    log =
      StarkBank.InvoicePullSubscription.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.InvoicePullSubscription.Log.get(log.id)
    assert get_log.id == log.id
    assert !is_nil(get_log.type)
    assert %StarkBank.InvoicePullSubscription{} = get_log.subscription
    assert !is_nil(get_log.subscription.id)
    assert is_list(get_log.errors)

    Enum.each(get_log.errors, fn error ->
      assert %StarkBank.Error{} = error
    end)
  end

  @tag :invoice_pull_subscription_log
  test "get! invoice_pull_subscription_log" do
    log =
      StarkBank.InvoicePullSubscription.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.InvoicePullSubscription.Log.get!(log.id)
    assert get_log.id == log.id
    assert %StarkBank.InvoicePullSubscription{} = get_log.subscription
  end

  @tag :invoice_pull_subscription_log
  test "page invoice_pull_subscription_log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.InvoicePullSubscription.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :invoice_pull_subscription_log
  test "page! invoice_pull_subscription_log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.InvoicePullSubscription.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
end
