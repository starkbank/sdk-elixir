defmodule StarkBankTest.WebhookEvent do
  use ExUnit.Case

  @content "{\"event\": {\"log\": {\"transfer\": {\"status\": \"processing\", \"updated\": \"2020-04-03T13:20:33.485644+00:00\", \"fee\": 160, \"name\": \"Lawrence James\", \"accountNumber\": \"10000-0\", \"id\": \"5107489032896512\", \"tags\": [], \"taxId\": \"91.642.017/0001-06\", \"created\": \"2020-04-03T13:20:32.530367+00:00\", \"amount\": 2, \"transactionIds\": [\"6547649079541760\"], \"bankCode\": \"01\", \"branchCode\": \"0001\"}, \"errors\": [], \"type\": \"sending\", \"id\": \"5648419829841920\", \"created\": \"2020-04-03T13:20:33.164373+00:00\"}, \"subscription\": \"transfer\", \"id\": \"6234355449987072\", \"created\": \"2020-04-03T13:20:40.784479+00:00\"}}"
  @signature "MEYCIQCmFCAn2Z+6qEHmf8paI08Ee5ZJ9+KvLWSS3ddp8+RF3AIhALlK7ltfRvMCXhjS7cy8SPlcSlpQtjBxmhN6ClFC0Tv6"
  @bad_signature "MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk="
  @malformed_signature "something is definitely wrong"

  @tag :event
  test "get, update and delete webhook event" do
    {:ok, query_event} =
      StarkBank.Event.query(limit: 1)
      |> Enum.take(1)
      |> hd

    {:ok, get_event} = StarkBank.Event.get(query_event.id)
    {:ok, delivered_event} = StarkBank.Event.update(get_event.id, is_delivered: true)
    {:ok, delete_event} = StarkBank.Event.delete(delivered_event.id)
    assert !is_nil(delete_event.id)
  end

  @tag :event
  test "get!, update! and delete! webhook event" do
    query_event =
      StarkBank.Event.query!(limit: 1, is_delivered: false)
      |> Enum.take(1)
      |> hd

    get_event = StarkBank.Event.get!(query_event.id)
    assert !get_event.is_delivered
    delivered_event = StarkBank.Event.update!(get_event.id, is_delivered: true)
    assert delivered_event.is_delivered
    delete_event = StarkBank.Event.delete!(delivered_event.id)
    assert !is_nil(delete_event.id)
  end

  @tag :event
  test "query webhook event" do
    StarkBank.Event.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :event
  test "query! webhook event" do
    StarkBank.Event.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :event
  test "parse webhook event" do
    {:ok, {_event, cache_pid_1}} =
      StarkBank.Event.parse(
        content: @content,
        signature: @signature
      )

    {:ok, {event, cache_pid_2}} =
      StarkBank.Event.parse(
        content: @content,
        signature: @signature,
        cache_pid: cache_pid_1
      )

    assert Agent.get(cache_pid_1, fn map -> Map.get(map, :starkbank_public_key) end) ==
             Agent.get(cache_pid_2, fn map -> Map.get(map, :starkbank_public_key) end)

    assert !is_nil(event.log)
  end

  @tag :event
  test "parse! webhook event" do
    {_event, cache_pid_1} =
      StarkBank.Event.parse!(
        content: @content,
        signature: @signature
      )

    {event, cache_pid_2} =
      StarkBank.Event.parse!(
        content: @content,
        signature: @signature,
        cache_pid: cache_pid_1
      )

    assert Agent.get(cache_pid_1, fn map -> Map.get(map, :starkbank_public_key) end) ==
             Agent.get(cache_pid_2, fn map -> Map.get(map, :starkbank_public_key) end)

    assert !is_nil(event.log)
  end

  @tag :event
  test "parse webhook event with invalid signature" do
    {:error, [error]} =
      StarkBank.Event.parse(
        content: @content,
        signature: @bad_signature
      )

    assert error.code == "invalidSignature"
  end

  @tag :event
  test "parse webhook event with malformed signature" do
    {:error, [error]} =
      StarkBank.Event.parse(
        content: @content,
        signature: @malformed_signature
      )

    assert error.code == "invalidSignature"
  end
end
