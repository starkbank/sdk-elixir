defmodule StarkBankTest.Transfer do
  use ExUnit.Case

  @tag :transfer
  test "create transfer" do
    {:ok, transfers} = StarkBank.Transfer.create([example_transfer()])
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
    file = File.open!("transfer.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  defp example_transfer() do
    %StarkBank.Transfer{
      amount: 10,
      name: "João",
      tax_id: "01234567890",
      bank_code: "01",
      branch_code:
        :crypto.rand_uniform(0, 9999)
        |> to_string
        |> String.pad_leading(4, "0"),
      account_number:
        :crypto.rand_uniform(0, 99999)
        |> to_string
        |> String.pad_leading(5, "0")
        |> (fn s -> s <> "-#{:crypto.rand_uniform(0, 9)}" end).()
    }
  end
end
