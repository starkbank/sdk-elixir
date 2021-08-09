defmodule StarkBankTest.UtilityPayment do
  use ExUnit.Case

  @tag :utility_payment
  test "create utility payment" do
    {:ok, payments} = StarkBank.UtilityPayment.create([example_payment(0, true)])
    payment = payments |> hd
    assert !is_nil(payment)
  end

  @tag :utility_payment
  test "create! utility payment" do
    payment = StarkBank.UtilityPayment.create!([example_payment(0, true)]) |> hd
    assert !is_nil(payment)
  end

  @tag :utility_payment
  test "query utility payment" do
    StarkBank.UtilityPayment.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :utility_payment
  test "query! utility payment" do
    StarkBank.UtilityPayment.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :utility_payment
  test "page utility payment" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.UtilityPayment.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :utility_payment
  test "page! utility payment" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.UtilityPayment.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :utility_payment
  test "get utility payment" do
    payment =
      StarkBank.UtilityPayment.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _payment} = StarkBank.UtilityPayment.get(payment.id)
  end

  @tag :utility_payment
  test "get! utility payment" do
    payment =
      StarkBank.UtilityPayment.query!()
      |> Enum.take(1)
      |> hd()

    _payment = StarkBank.UtilityPayment.get!(payment.id)
  end

  @tag :utility_payment
  test "pdf utility payment" do
    payment =
      StarkBank.UtilityPayment.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    {:ok, _pdf} = StarkBank.UtilityPayment.pdf(payment.id)
  end

  @tag :utility_payment
  test "pdf! utility payment" do
    payment =
      StarkBank.UtilityPayment.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    pdf = StarkBank.UtilityPayment.pdf!(payment.id)
    file = File.open!("tmp/utility-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end

  @tag :utility_payment
  test "delete utility payment" do
    payment = StarkBank.UtilityPayment.create!([example_payment(2, true)]) |> hd
    {:ok, deleted_payment} = StarkBank.UtilityPayment.delete(payment.id)
    assert !is_nil(deleted_payment)
  end

  @tag :utility_payment
  test "delete! utility payment" do
    payment = StarkBank.UtilityPayment.create!([example_payment(2, true)]) |> hd
    deleted_payment = StarkBank.UtilityPayment.delete!(payment.id)
    assert !is_nil(deleted_payment)
  end

  def example_payment(schedule \\ 0, push_schedule)

  def example_payment(schedule, true) do
    %{example_payment(schedule, false) | scheduled: Date.utc_today() |> Date.add(schedule)}
  end

  def example_payment(_, false) do
    bar_code_core =
      :rand.uniform(100_000)
      |> to_string
      |> String.pad_leading(11, "0")

    %StarkBank.UtilityPayment{
      bar_code: "8366" <> bar_code_core <> "01380074119002551100010601813",
      description: "pagando a conta",
      tags: ["my", "precious", "tags"]
    }
  end
end
