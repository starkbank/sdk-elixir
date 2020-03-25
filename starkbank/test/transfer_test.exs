defmodule StarkBankTest.Transfer do
  use ExUnit.Case

  @tag :exclude
  test "create transfer" do
    user = StarkBankTest.Credentials.project()
    {:ok, transfers} = StarkBank.Transfer.create(user, [example_transfer()])
    transfer = transfers |> hd
    assert !is_nil(transfer)
  end

  @tag :exclude
  test "create! transfer" do
    user = StarkBankTest.Credentials.project()
    transfer = StarkBank.Transfer.create!(user, [example_transfer()]) |> hd
    assert !is_nil(transfer)
  end

  @tag :exclude
  test "query transfer" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Transfer.query(user, limit: 101)
     |> Enum.take(101)
     |> (fn list -> assert length(list) == 101 end).()
  end

  @tag :exclude
  test "query! transfer" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Transfer.query!(user, limit: 101)
     |> Enum.take(101)
     |> (fn list -> assert length(list) == 101 end).()
  end

  @tag :exclude
  test "get transfer" do
    user = StarkBankTest.Credentials.project()
    transfer = StarkBank.Transfer.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _transfer} = StarkBank.Transfer.get(user, transfer.id)
  end

  @tag :exclude
  test "get! transfer" do
    user = StarkBankTest.Credentials.project()
    transfer = StarkBank.Transfer.query!(user)
     |> Enum.take(1)
     |> hd()
    _transfer = StarkBank.Transfer.get!(user, transfer.id)
  end

  @tag :exclude
  test "pdf transfer" do
    user = StarkBankTest.Credentials.project()
    transfer = StarkBank.Transfer.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _pdf} = StarkBank.Transfer.pdf(user, transfer.id)
  end

  @tag :exclude
  test "pdf! transfer" do
    user = StarkBankTest.Credentials.project()
    transfer = StarkBank.Transfer.query!(user)
     |> Enum.take(1)
     |> hd()
    pdf = StarkBank.Transfer.pdf!(user, transfer.id)
    file = File.open!("transfer.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  defp example_transfer() do
    %StarkBank.Transfer.Data{
      amount: 10,
      name: "João",
      tax_id: "01234567890",
      bank_code: "01",
      branch_code: :crypto.rand_uniform(0, 9999)
       |> to_string
       |> String.pad_leading(4, "0"),
      account_number: :crypto.rand_uniform(0, 99999)
       |> to_string
       |> String.pad_leading(5, "0")
       |> (fn s -> s <> "-#{:crypto.rand_uniform(0, 9)}" end).()
    }
  end
end
