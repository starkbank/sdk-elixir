defmodule StarkBankTest.InvoicePullSubscription do
  use ExUnit.Case

  @tag :invoice_pull_subscription
  test "create invoice_pull_subscription" do
    {:ok, [subscription]} = StarkBank.InvoicePullSubscription.create([example_invoice_pull_subscription()])
    assert !is_nil(subscription.id)
    assert !is_nil(subscription.status)
  end

  @tag :invoice_pull_subscription
  test "create! invoice_pull_subscription" do
    [subscription] = StarkBank.InvoicePullSubscription.create!([example_invoice_pull_subscription()])
    assert !is_nil(subscription.id)
  end

  @tag :invoice_pull_subscription
  test "query invoice_pull_subscription" do
    StarkBank.InvoicePullSubscription.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :invoice_pull_subscription
  test "query! invoice_pull_subscription" do
    StarkBank.InvoicePullSubscription.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :invoice_pull_subscription
  test "page invoice_pull_subscription" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.InvoicePullSubscription.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :invoice_pull_subscription
  test "page! invoice_pull_subscription" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.InvoicePullSubscription.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :invoice_pull_subscription
  test "get invoice_pull_subscription" do
    subscription =
      StarkBank.InvoicePullSubscription.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_subscription} = StarkBank.InvoicePullSubscription.get(subscription.id)
    assert get_subscription.id == subscription.id
  end

  @tag :invoice_pull_subscription
  test "get! invoice_pull_subscription" do
    subscription =
      StarkBank.InvoicePullSubscription.query!()
      |> Enum.take(1)
      |> hd()

    get_subscription = StarkBank.InvoicePullSubscription.get!(subscription.id)
    assert get_subscription.id == subscription.id
  end

  @tag :invoice_pull_subscription
  test "cancel and cancel! invoice_pull_subscription" do
    {:ok, [first]} = StarkBank.InvoicePullSubscription.create([example_invoice_pull_subscription()])
    [second] = StarkBank.InvoicePullSubscription.create!([example_invoice_pull_subscription()])

    {:ok, canceled_subscription} = StarkBank.InvoicePullSubscription.cancel(first.id)
    assert canceled_subscription.status == "canceled"

    canceled_subscription! = StarkBank.InvoicePullSubscription.cancel!(second.id)
    assert canceled_subscription!.status == "canceled"
  end

  def example_invoice_pull_subscription() do
    %StarkBank.InvoicePullSubscription{
      start: Date.utc_today() |> Date.add(1),
      interval: "month",
      pull_mode: "manual",
      pull_retry_limit: 3,
      type: "qrcode",
      amount: 100,
      external_id: "invoice-pull-subscription-" <> (:rand.uniform(1_000_000) |> Integer.to_string()),
      tags: ["invoice", "pull"]
    }
  end
end
