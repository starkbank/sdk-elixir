defmodule StarkBankTest.WebhookEvent do
  use ExUnit.Case

  @content "{\"event\": {\"log\": {\"transfer\": {\"status\": \"failed\", \"updated\": \"2020-03-13T14:49:10.189611+00:00\", \"fee\": 200, \"name\": \"Richard Jenkins\", \"accountNumber\": \"10000-0\", \"id\": \"5599003076984832\", \"tags\": [\"19581e27de7ced00ff1ce50b2047e7a567c76b1cbaebabe5ef03f7c3017bb5b7\"], \"taxId\": \"81.680.513/0001-92\", \"created\": \"2020-03-13T14:49:09.943811+00:00\", \"amount\": 295136516, \"transactionIds\": [\"invalidBalance\"], \"bankCode\": \"01\", \"branchCode\": \"0001\"}, \"errors\": [\"invalidbalance\"], \"type\": \"failed\", \"id\": \"6046244933730304\", \"created\": \"2020-03-13T14:49:10.189586+00:00\"}, \"delivered\": null, \"subscription\": \"transfer\", \"id\": \"6270003208781824\", \"created\": \"2020-03-13T14:49:11.236120+00:00\"}}"
  @signature "MEQCIGVKEnnhLFHjxKM+nDggweTsFEQOIsmnZkep2Ni5o8FeAiAVm//jnu3vmh9lxq1HRQcRW7SsMlqSGNERaa1CvnVnNA=="
  @bad_signature "MEYCIQC+0fzgh+WX6Af0hm9FsnWmsRaeQbTHI9vITB0d+lg9QwIhAMpz2xBRLm8dO+E4NQZXVxtxLJylkS1rqdlB06PQGIub"

  @tag :webhook_event
  test "get, set_delivered and delete webhook event" do
    user = StarkBankTest.Credentials.project()
    {:ok, query_event} = StarkBank.Webhook.Event.query(user, limit: 1)
     |> Enum.take(1)
     |> hd
    {:ok, get_event} = StarkBank.Webhook.Event.get(user, query_event.id)
    {:ok, delivered_event} = StarkBank.Webhook.Event.set_delivered(user, get_event.id)
    {:ok, delete_event} = StarkBank.Webhook.Event.delete(user, delivered_event.id)
    assert !is_nil(delete_event.id)
  end

  @tag :webhook_event
  test "get!, set_delivered! and delete! webhook event" do
    user = StarkBankTest.Credentials.project()
    query_event = StarkBank.Webhook.Event.query!(user, limit: 1)
     |> Enum.take(1)
     |> hd
    get_event = StarkBank.Webhook.Event.get!(user, query_event.id)
    delivered_event = StarkBank.Webhook.Event.set_delivered!(user, get_event.id)
    delete_event = StarkBank.Webhook.Event.delete!(user, delivered_event.id)
    assert !is_nil(delete_event.id)
  end

  @tag :webhook_event
  test "query webhook event" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Webhook.Event.query(user, limit: 5)
     |> Enum.take(5)
     |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :webhook_event
  test "query! webhook event" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Webhook.Event.query!(user, limit: 5)
     |> Enum.take(5)
     |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :webhook_event
  test "parse webhook event" do
    user = StarkBankTest.Credentials.project()
    {:ok, {_event, public_key}} = StarkBank.Webhook.Event.parse(
      user,
      @content,
      @signature,
      nil
    )
    {:ok, {event, public_key_2}} = StarkBank.Webhook.Event.parse(
      user,
      @content,
      @signature,
      public_key
    )
    assert public_key == public_key_2
    assert !is_nil(event.log)
  end

  @tag :webhook_event
  test "parse! webhook event" do
    user = StarkBankTest.Credentials.project()
    {_event, public_key} = StarkBank.Webhook.Event.parse!(
      user,
      @content,
      @signature,
      nil
    )
    {event, public_key_2} = StarkBank.Webhook.Event.parse!(
      user,
      @content,
      @signature,
      public_key
    )
    assert public_key == public_key_2
    assert !is_nil(event.log)
  end

  @tag :webhook_event
  test "parse fake webhook event" do
    user = StarkBankTest.Credentials.project()
    {:error, [error]} = StarkBank.Webhook.Event.parse(
      user,
      @content,
      @bad_signature,
      nil
    )
    assert error.code == "invalidSignature"
  end
end
