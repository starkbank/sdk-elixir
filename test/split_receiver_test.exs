defmodule StarkBankTest.SplitReceiver do
  use ExUnit.Case

  @tag :split_receiver
  test "create split_receiver" do
    {:ok, [receiver]} = StarkBank.SplitReceiver.create([example_split_receiver()])
    assert !is_nil(receiver.id)
    assert !is_nil(receiver.status)
  end

  @tag :split_receiver
  test "create! split_receiver" do
    [receiver] = StarkBank.SplitReceiver.create!([example_split_receiver()])
    assert !is_nil(receiver.id)
  end

  @tag :split_receiver
  test "query split_receiver" do
    StarkBank.SplitReceiver.query(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_receiver
  test "query! split_receiver" do
    StarkBank.SplitReceiver.query!(limit: 5)
    |> Enum.take(5)
    |> (fn list -> assert length(list) <= 5 end).()
  end

  @tag :split_receiver
  test "page split_receiver" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.SplitReceiver.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split_receiver
  test "page! split_receiver" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.SplitReceiver.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :split_receiver
  test "get split_receiver" do
    receiver =
      StarkBank.SplitReceiver.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_receiver} = StarkBank.SplitReceiver.get(receiver.id)
    assert get_receiver.id == receiver.id
  end

  @tag :split_receiver
  test "get! split_receiver" do
    receiver =
      StarkBank.SplitReceiver.query!()
      |> Enum.take(1)
      |> hd()

    get_receiver = StarkBank.SplitReceiver.get!(receiver.id)
    assert get_receiver.id == receiver.id
  end

  def example_split_receiver() do
    %StarkBank.SplitReceiver{
      name: "Jaime Lannister",
      tax_id: "012.345.678-90",
      bank_code: "20018183",
      branch_code: "0001",
      account_number: "6" <> (:rand.uniform(999_999) |> Integer.to_string() |> String.pad_leading(6, "0")),
      account_type: "checking",
      tags: ["Jaime", "Lannister"]
    }
  end
end
