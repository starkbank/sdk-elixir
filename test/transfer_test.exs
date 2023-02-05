defmodule StarkBankTest.Transfer do
  use ExUnit.Case

  @tag :transfer
  test "create transfer" do
    {:ok, transfers} = StarkBank.Transfer.create([example_transfer(true)])
    transfer = transfers |> hd
    assert !is_nil(transfer)
  end

  @tag :transfer
  test "create! transfer" do
    transfer = StarkBank.Transfer.create!([example_transfer()]) |> hd
    assert !is_nil(transfer)
  end

  @tag :transfer
  test "query transfer" do
    StarkBank.Transfer.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :transfer
  test "query! transfer" do
    StarkBank.Transfer.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :transfer
  test "query transfer ids" do
    transfers_ids_expected =
      StarkBank.Transfer.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, transfer} -> transfer.id end)

    assert length(transfers_ids_expected) <= 10

    transfers_ids_result =
      StarkBank.Transfer.query(ids: transfers_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, transfer} -> transfer.id end)

    assert length(transfers_ids_result) <= 10

    transfers_ids_expected = Enum.sort(transfers_ids_expected)
    transfers_ids_result = Enum.sort(transfers_ids_result)

    assert transfers_ids_expected == transfers_ids_result
  end

  @tag :transfer
  test "query! transfer ids" do
    transfers_ids_expected =
      StarkBank.Transfer.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn transfer -> transfer.id end)

    assert length(transfers_ids_expected) <= 10

    transfers_ids_result =
      StarkBank.Transfer.query!(ids: transfers_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn transfer -> transfer.id end)

    assert length(transfers_ids_result) <= 10

    transfers_ids_expected = Enum.sort(transfers_ids_expected)
    transfers_ids_result = Enum.sort(transfers_ids_result)

    assert transfers_ids_expected == transfers_ids_result
  end

  @tag :transfer
  test "page transfer" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Transfer.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :transfer
  test "page! transfer" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Transfer.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :transfer
  test "get transfer" do
    transfer =
      StarkBank.Transfer.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _transfer} = StarkBank.Transfer.get(transfer.id)
  end

  @tag :transfer
  test "get! transfer" do
    transfer =
      StarkBank.Transfer.query!()
      |> Enum.take(1)
      |> hd()

    _transfer = StarkBank.Transfer.get!(transfer.id)
  end

  @tag :transfer
  test "delete transfer" do
    created_transfer =
      StarkBank.Transfer.create!([example_transfer(true)]) |> hd
    {:ok, deleted_transfer} = StarkBank.Transfer.delete(created_transfer.id)
    "canceled" = deleted_transfer.status
  end

  @tag :transfer
  test "delete! transfer" do
    created_transfer =
      StarkBank.Transfer.create!([example_transfer(true)]) |> hd
    deleted_transfer = StarkBank.Transfer.delete!(created_transfer.id)
    "canceled" = deleted_transfer.status
  end

  @tag :transfer
  test "pdf transfer" do
    transfer =
      StarkBank.Transfer.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    {:ok, _pdf} = StarkBank.Transfer.pdf(transfer.id)
  end

  @tag :transfer
  test "pdf! transfer" do
    transfer =
      StarkBank.Transfer.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    pdf = StarkBank.Transfer.pdf!(transfer.id)
    file = File.open!("tmp/transfer.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  def example_transfer(push_schedule \\ false)

  def example_transfer(push_schedule) when push_schedule do
    rand = Enum.random(0..1)
    cond do
      rand == 0 -> %{example_transfer(false) | scheduled: Date.utc_today() |> Date.add(1)}
      rand == 1 -> %{example_transfer(false) | scheduled: DateTime.utc_now() |> DateTime.add(86400, :second)}
    end
  end

  def example_transfer(_push_schedule) do
    %StarkBank.Transfer{
      amount: 10,
      name: "João",
      tax_id: "01234567890",
      bank_code: "01",
      branch_code:
        :rand.uniform(9999)
        |> to_string
        |> String.pad_leading(4, "0"),
      account_number:
        :rand.uniform(99999)
        |> to_string
        |> String.pad_leading(5, "0")
        |> (fn s -> s <> "-#{:rand.uniform(9)}" end).(),
      account_type: ["checking", "savings", "salary", "payment"] |> Enum.random(),
      external_id: "elixir-#{:rand.uniform(9999999999)}",
      rules: [
        %StarkBank.Transfer.Rule{
          keu: "resendingLimit",
          value: 5
        }
      ]
    }
  end
end
