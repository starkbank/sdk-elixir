defmodule StarkBankTest.DasPayment do
  use ExUnit.Case

  @tag :das_payment
  test "create DAS payment" do
    {:ok, payments} = StarkBank.DasPayment.create([example_payment()])
    payment = payments |> hd
    assert !is_nil(payment)
  end

  @tag :das_payment
  test "create! DAS payment" do
    payment = StarkBank.DasPayment.create!([example_payment()]) |> hd
    assert !is_nil(payment)
  end

  @tag :das_payment
  test "query DAS payment" do
    StarkBank.DasPayment.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :das_payment
  test "query! DAS payment" do
    StarkBank.DasPayment.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :das_payment
  test "get DAS payment" do
    payment =
      StarkBank.DasPayment.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _payment} = StarkBank.DasPayment.get(payment.id)
  end

  @tag :das_payment
  test "get! DAS payment" do
    payment =
      StarkBank.DasPayment.query!()
      |> Enum.take(1)
      |> hd()

    _payment = StarkBank.DasPayment.get!(payment.id)
  end

  @tag :das_payment
  test "pdf DAS payment" do
    payment =
      StarkBank.DasPayment.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    {:ok, _pdf} = StarkBank.DasPayment.pdf(payment.id)
  end

  @tag :das_payment
  test "pdf! DAS payment" do
    payment =
      StarkBank.DasPayment.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    pdf = StarkBank.DasPayment.pdf!(payment.id)
    file = File.open!("tmp/DAS-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :das_payment
  test "delete DAS payment" do
    payment = StarkBank.DasPayment.create!([example_payment(2)]) |> hd
    {:ok, deleted_payment} = StarkBank.DasPayment.delete(payment.id)
    assert !is_nil(deleted_payment)
  end

  @tag :das_payment
  test "delete! DAS payment" do
    payment = StarkBank.DasPayment.create!([example_payment(2)]) |> hd
    deleted_payment = StarkBank.DasPayment.delete!(payment.id)
    assert !is_nil(deleted_payment)
  end

  defp example_payment(schedule \\ 0) do
    bar_code_core =
      :crypto.rand_uniform(100, 100_000)
      |> to_string
      |> String.pad_leading(11, "0")

    %StarkBank.DasPayment{
      bar_code: "8366" <> bar_code_core <> "01380074119002551100010601813",
      scheduled: Date.utc_today() |> Date.add(schedule),
      description: "pagando a conta",
      tags: ["my", "precious", "tags"]
    }
  end
end
