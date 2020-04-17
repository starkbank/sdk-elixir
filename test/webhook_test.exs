defmodule StarkBankTest.Webhook do
  use ExUnit.Case

  @tag :webhook
  test "create, get and delete webhook" do
    user = StarkBankTest.Credentials.project()
    {:ok, create_webhook} = StarkBank.Webhook.create(
      user,
      "https://webhook.site/60e9c18e-4b5c-4369-bda1-ab5fcd8e1b29",
      ["transfer", "boleto", "boleto-payment", "utility-payment"]
    )
    {:ok, get_webhook} = StarkBank.Webhook.get(user, create_webhook.id)
    {:ok, delete_webhook} = StarkBank.Webhook.delete(user, get_webhook.id)
    assert !is_nil(delete_webhook)
  end

  @tag :webhook
  test "create!, get! and delete! webhook" do
    user = StarkBankTest.Credentials.project()
    create_webhook = StarkBank.Webhook.create!(
      user,
      "https://webhook.site/60e9c18e-4b5c-4369-bda1-ab5fcd8e1b29",
      ["transfer", "boleto", "boleto-payment", "utility-payment"]
    )
    get_webhook = StarkBank.Webhook.get!(user, create_webhook.id)
    delete_webhook = StarkBank.Webhook.delete!(user, get_webhook.id)
    assert !is_nil(delete_webhook)
  end

  @tag :webhook
  test "query webhook" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Webhook.query(user, limit: 5)
     |> Enum.take(5)
     |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :webhook
  test "query! webhook" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Webhook.query!(user, limit: 5)
     |> Enum.take(5)
     |> (fn list -> assert length(list) <= 5 end).()
  end
end
