defmodule StarkBankTest.UtilityPayment do
  use ExUnit.Case

  @tag :utility_payment
  test "create utility payment" do
    user = StarkBankTest.Credentials.project()
    {:ok, payments} = StarkBank.Payment.Utility.create(user, [example_payment()])
    payment = payments |> hd
    assert !is_nil(payment)
  end

  @tag :utility_payment
  test "create! utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.create!(user, [example_payment()]) |> hd
    assert !is_nil(payment)
  end

  @tag :utility_payment
  test "query utility payment" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Utility.query(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :utility_payment
  test "query! utility payment" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Utility.query!(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :utility_payment
  test "get utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _payment} = StarkBank.Payment.Utility.get(user, payment.id)
  end

  @tag :utility_payment
  test "get! utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.query!(user)
     |> Enum.take(1)
     |> hd()
    _payment = StarkBank.Payment.Utility.get!(user, payment.id)
  end

  @tag :utility_payment
  test "pdf utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.query!(user, status: "created")
     |> Enum.take(1)
     |> hd()
    {:ok, _pdf} = StarkBank.Payment.Utility.pdf(user, payment.id)
  end

  @tag :utility_payment
  test "pdf! utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.query!(user, status: "created")
     |> Enum.take(1)
     |> hd()
    pdf = StarkBank.Payment.Utility.pdf!(user, payment.id)
    file = File.open!("utility-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :utility_payment
  test "delete utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.create!(user, [example_payment(2)]) |> hd
    {:ok, deleted_payment} = StarkBank.Payment.Utility.delete(user, payment.id)
    assert !is_nil(deleted_payment)
  end

  @tag :utility_payment
  test "delete! utility payment" do
    user = StarkBankTest.Credentials.project()
    payment = StarkBank.Payment.Utility.create!(user, [example_payment(2)]) |> hd
    deleted_payment = StarkBank.Payment.Utility.delete!(user, payment.id)
    assert !is_nil(deleted_payment)
  end

  defp example_payment(schedule \\ 0) do
    bar_code_core = :crypto.rand_uniform(100, 100000)
       |> to_string
       |> String.pad_leading(11, "0")

    %StarkBank.Payment.Utility.Data{
      bar_code: "8366" <> bar_code_core <> "01380074119002551100010601813",
      scheduled: Date.utc_today() |> Date.add(schedule),
      description: "pagando a conta",
      tags: ["my", "precious", "tags"],
    }
  end
end
