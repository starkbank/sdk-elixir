defmodule StarkBankTest.SplitReceiverLog do
  use ExUnit.Case

  @tag :split_receiver_log
  test "query split_receiver_log" do
    StarkBank.SplitReceiver.Log.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_receiver_log
  test "query! split_receiver_log" do
    StarkBank.SplitReceiver.Log.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_receiver_log
  test "get split_receiver_log" do
    log =
      StarkBank.SplitReceiver.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.SplitReceiver.Log.get(log.id)
    assert get_log.id == log.id
    assert !is_nil(get_log.type)
    assert %StarkBank.SplitReceiver{} = get_log.receiver
    assert !is_nil(get_log.receiver.id)
    assert is_list(get_log.errors)

    Enum.each(get_log.errors, fn error ->
      assert %StarkBank.Error{} = error
    end)
  end

  @tag :split_receiver_log
  test "get! split_receiver_log" do
    log =
      StarkBank.SplitReceiver.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.SplitReceiver.Log.get!(log.id)
    assert get_log.id == log.id
    assert %StarkBank.SplitReceiver{} = get_log.receiver
  end

  @tag :split_receiver_log
  test "page split_receiver_log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.SplitReceiver.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split_receiver_log
  test "page! split_receiver_log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.SplitReceiver.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
end
