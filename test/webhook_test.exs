defmodule StarkBankTest.Webhook do
  use ExUnit.Case

  @tag :webhook
  test "create, get and delete webhook" do
    {:ok, create_webhook} =
      StarkBank.Webhook.create(
        url: "https://webhook.site/a10b29fc-45cf-4a09-b743-b7dff8c9eea5",
        subscriptions: ["transfer", "boleto", "boleto-payment", "utility-payment"]
      )

    {:ok, get_webhook} = StarkBank.Webhook.get(create_webhook.id)
    {:ok, delete_webhook} = StarkBank.Webhook.delete(get_webhook.id)
    assert !is_nil(delete_webhook)
  end

  @tag :webhook
  test "create!, get! and delete! webhook" do
    create_webhook =
      StarkBank.Webhook.create!(
        url: "https://webhook.site/a10b29fc-45cf-4a09-b743-b7dff8c9eea5",
        subscriptions: ["transfer", "deposit", "brcode-payment", "utility-payment"]
      )

    get_webhook = StarkBank.Webhook.get!(create_webhook.id)
    delete_webhook = StarkBank.Webhook.delete!(get_webhook.id)
    assert !is_nil(delete_webhook)
  end

  @tag :webhook
  test "query webhook" do
    StarkBank.Webhook.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :webhook
  test "query! webhook" do
    StarkBank.Webhook.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :webhook
  test "page webhook" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Webhook.page/1, 2, limit: 2)
    assert length(ids) <= 4
  end

  @tag :webhook
  test "page! webhook" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Webhook.page!/1, 2, limit: 2)
    assert length(ids) <= 4
  end

end
