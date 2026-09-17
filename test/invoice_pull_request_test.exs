defmodule StarkBankTest.InvoicePullRequest do
  use ExUnit.Case

  @tag :invoice_pull_request
  test "create invoice_pull_request" do
    {:ok, [request]} = StarkBank.InvoicePullRequest.create([example_invoice_pull_request()])
    assert !is_nil(request.id)
    assert !is_nil(request.status)
  end

  @tag :invoice_pull_request
  test "create! invoice_pull_request" do
    [request] = StarkBank.InvoicePullRequest.create!([example_invoice_pull_request()])
    assert !is_nil(request.id)
  end

  @tag :invoice_pull_request
  test "query invoice_pull_request" do
    StarkBank.InvoicePullRequest.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :invoice_pull_request
  test "query! invoice_pull_request" do
    StarkBank.InvoicePullRequest.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :invoice_pull_request
  test "page invoice_pull_request" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.InvoicePullRequest.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :invoice_pull_request
  test "page! invoice_pull_request" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.InvoicePullRequest.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :invoice_pull_request
  test "get invoice_pull_request" do
    request =
      StarkBank.InvoicePullRequest.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_request} = StarkBank.InvoicePullRequest.get(request.id)
    assert get_request.id == request.id
  end

  @tag :invoice_pull_request
  test "get! invoice_pull_request" do
    request =
      StarkBank.InvoicePullRequest.query!()
      |> Enum.take(1)
      |> hd()

    get_request = StarkBank.InvoicePullRequest.get!(request.id)
    assert get_request.id == request.id
  end

  @tag :invoice_pull_request
  test "cancel and cancel! invoice_pull_request" do
    {:ok, [first]} = StarkBank.InvoicePullRequest.create([example_invoice_pull_request()])
    [second] = StarkBank.InvoicePullRequest.create!([example_invoice_pull_request()])

    {:ok, canceled_request} = StarkBank.InvoicePullRequest.cancel(first.id)
    assert canceled_request.status == "canceled"

    canceled_request! = StarkBank.InvoicePullRequest.cancel!(second.id)
    assert canceled_request!.status == "canceled"
  end

  def example_invoice_pull_request() do
    invoice = StarkBank.Invoice.create!([StarkBankTest.Invoice.example_invoice()]) |> hd()

    [subscription] =
      StarkBank.InvoicePullSubscription.create!([
        StarkBankTest.InvoicePullSubscription.example_invoice_pull_subscription()
      ])

    %StarkBank.InvoicePullRequest{
      subscription_id: subscription.id,
      invoice_id: invoice.id,
      due: DateTime.utc_now() |> DateTime.add(2 * 24 * 60 * 60, :second),
      attempt_type: "default",
      external_id: "invoice-pull-request-" <> (:rand.uniform(1_000_000) |> Integer.to_string()),
      tags: ["invoice", "pull"]
    }
  end
end
