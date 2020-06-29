defmodule StarkBankTest.IssPayment do
  use ExUnit.Case

  @tag :iss_payment
  test "create ISS payment" do
    {:ok, payments} = StarkBank.IssPayment.create([example_payment()])
    payment = payments |> hd
    assert !is_nil(payment)
  end

  @tag :iss_payment
  test "create! ISS payment" do
    payment = StarkBank.IssPayment.create!([example_payment()]) |> hd
    assert !is_nil(payment)
  end

  @tag :iss_payment
  test "query ISS payment" do
    StarkBank.IssPayment.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :iss_payment
  test "query! ISS payment" do
    StarkBank.IssPayment.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :iss_payment
  test "get ISS payment" do
    payment =
      StarkBank.IssPayment.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _payment} = StarkBank.IssPayment.get(payment.id)
  end

  @tag :iss_payment
  test "get! ISS payment" do
    payment =
      StarkBank.IssPayment.query!()
      |> Enum.take(1)
      |> hd()

    _payment = StarkBank.IssPayment.get!(payment.id)
  end

  @tag :iss_payment
  test "pdf ISS payment" do
    payment =
      StarkBank.IssPayment.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    {:ok, _pdf} = StarkBank.IssPayment.pdf(payment.id)
  end

  @tag :iss_payment
  test "pdf! ISS payment" do
    payment =
      StarkBank.IssPayment.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    pdf = StarkBank.IssPayment.pdf!(payment.id)
    file = File.open!("tmp/ISS-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :iss_payment
  test "delete ISS payment" do
    payment = StarkBank.IssPayment.create!([example_payment(2)]) |> hd
    {:ok, deleted_payment} = StarkBank.IssPayment.delete(payment.id)
    assert !is_nil(deleted_payment)
  end

  @tag :iss_payment
  test "delete! ISS payment" do
    payment = StarkBank.IssPayment.create!([example_payment(2)]) |> hd
    deleted_payment = StarkBank.IssPayment.delete!(payment.id)
    assert !is_nil(deleted_payment)
  end

  defp example_payment(schedule \\ 0) do
    bar_code_core =
      :crypto.rand_uniform(100, 100_000)
      |> to_string
      |> String.pad_leading(11, "0")

    %StarkBank.IssPayment{
      bar_code: "8366" <> bar_code_core <> "01380074119002551100010601813",
      scheduled: Date.utc_today() |> Date.add(schedule),
      description: "pagando a conta",
      tags: ["my", "precious", "tags"]
    }
  end
end
