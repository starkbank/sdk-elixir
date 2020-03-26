defmodule StarkBankTest.UtilityPayment do
  use ExUnit.Case

  @tag :exclude
  test "create utility payment" do
    user = StarkBankTest.Credentials.project()
    {:ok, payments} = StarkBank.Payment.Utility.create(user, [example_payment()])
    payment = payments |> hd
    assert !is_nil(payment)
  end

  @tag :exclude
  test "create! utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.create!(user, [example_payment()]) |> hd
    assert !is_nil(payment)
  end

  @tag :exclude
  test "query utility payment" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Utility.query(user, limit: 101)
     |> Enum.take(101)
     |> (fn list -> assert length(list) == 101 end).()
  end

  @tag :exclude
  test "query! utility payment" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Utility.query!(user, limit: 101)
     |> Enum.take(101)
     |> (fn list -> assert length(list) == 101 end).()
  end

  @tag :exclude
  test "get utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _payment} = StarkBank.Payment.Utility.get(user, payment.id)
  end

  @tag :exclude
  test "get! utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.query!(user)
     |> Enum.take(1)
     |> hd()
    _payment = StarkBank.Payment.Utility.get!(user, payment.id)
  end

  @tag :exclude
  test "pdf utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.query!(user, status: "success")
     |> Enum.take(1)
     |> hd()
    {:ok, _pdf} = StarkBank.Payment.Utility.pdf(user, payment.id)
  end

  @tag :exclude
  test "pdf! utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.query!(user, status: "success")
     |> Enum.take(1)
     |> hd()
    pdf = StarkBank.Payment.Utility.pdf!(user, payment.id)
    file = File.open!("utility-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :exclude
  test "delete utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.create!(user, [example_payment()]) |> hd
    {:ok, deleted_payment} = StarkBank.Payment.Utility.delete(user, payment.id)
    assert !is_nil(deleted_payment)
  end

  @tag :exclude
  test "delete! utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.create!(user, [example_payment()]) |> hd
    deleted_payment = StarkBank.Payment.Utility.delete!(user, payment.id)
    assert !is_nil(deleted_payment)
  end

  defp example_payment() do
    bar_code_core = :crypto.rand_uniform(100, 100000)
       |> to_string
       |> String.pad_leading(11, "0")

    %StarkBank.Payment.Utility.Data{
      bar_code: "8366" <> bar_code_core <> "01380074119002551100010601813",
      scheduled: Date.utc_today() |> Date.add(1),
      description: "pagando a conta",
      tags: ["my", "precious", "tags"],
    }
  end
end
