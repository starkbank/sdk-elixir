defmodule StarkBankTest.DarfPayment do
  use ExUnit.Case
  
  @tag :darf_payment
  test "create darf payment" do
    {:ok, payments} = StarkBank.DarfPayment.create([example_payment(2, true)])
    payment = payments |> hd
    assert !is_nil(payment)
  end
  
  @tag :darf_payment
  test "create! darf payment" do
    payment = StarkBank.DarfPayment.create!([example_payment(2, true)]) |> hd
    assert !is_nil(payment)
  end
  
  @tag :darf_payment
  test "query darf payment" do
    StarkBank.DarfPayment.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end
  
  @tag :darf_payment
  test "query! darf payment" do
    StarkBank.DarfPayment.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end
  
  @tag :darf_payment
  test "query payment ids" do
    payments_ids_expected =
    StarkBank.DarfPayment.query(limit: 10)
    |> Enum.take(100)
    |> Enum.map(fn {:ok, payment} -> payment.id end)
  
    assert length(payments_ids_expected) <= 10
  
    payments_ids_result =
    StarkBank.DarfPayment.query(ids: payments_ids_expected)
    |> Enum.take(100)
    |> Enum.map(fn {:ok, payment} -> payment.id end)
  
    assert length(payments_ids_result) <= 10
  
    payments_ids_expected = Enum.sort(payments_ids_expected)
    payments_ids_result = Enum.sort(payments_ids_result)
  
    assert payments_ids_expected == payments_ids_result
  end
  
  @tag :darf_payment
  test "query! payment ids" do
    payments_ids_expected =
    StarkBank.DarfPayment.query!(limit: 10)
    |> Enum.take(100)
    |> Enum.map(fn payment -> payment.id end)
  
    assert length(payments_ids_expected) <= 10
  
    payments_ids_result =
    StarkBank.DarfPayment.query!(ids: payments_ids_expected)
    |> Enum.take(100)
    |> Enum.map(fn payment -> payment.id end)
  
    assert length(payments_ids_result) <= 10
  
    payments_ids_expected = Enum.sort(payments_ids_expected)
    payments_ids_result = Enum.sort(payments_ids_result)
  
    assert payments_ids_expected == payments_ids_result
  end
  
  @tag :darf_payment
  test "page darf payment" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.DarfPayment.page/1, 2, limit: 5)
    assert length(ids) == 10
  end
  
  @tag :darf_payment
  test "page! darf payment" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.DarfPayment.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
  
  @tag :darf_payment
  test "get darf payment" do
    payment =
    StarkBank.DarfPayment.query!()
    |> Enum.take(1)
    |> hd()
  
    {:ok, _payment} = StarkBank.DarfPayment.get(payment.id)
  end
  
  @tag :darf_payment
  test "get! darf payment" do
    payment =
    StarkBank.DarfPayment.query!()
    |> Enum.take(1)
    |> hd()
  
    _payment = StarkBank.DarfPayment.get!(payment.id)
  end

  @tag :darf_payment
  test "pdf darf payment" do
    payment =
    StarkBank.DarfPayment.query!(status: "success")
    |> Enum.take(1)
    |> hd()
  
    {:ok, _pdf} = StarkBank.DarfPayment.pdf(payment.id)
  end
  
  @tag :darf_payment
  test "pdf! darf payment" do
    payment =
    StarkBank.DarfPayment.query!(status: "success")
    |> Enum.take(1)
    |> hd()
  
    pdf = StarkBank.DarfPayment.pdf!(payment.id)
    file = File.open!("tmp/darf-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end
  
  @tag :darf_payment
  test "delete darf payment" do
    created_payment =
    StarkBank.DarfPayment.create!([example_payment(2, true)]) |> hd
    {:ok, deleted_payment} = StarkBank.DarfPayment.delete(created_payment.id)
    "canceled" = deleted_payment.status
  end
  
  @tag :darf_payment
  test "delete! darf payment" do
    created_payment =
    StarkBank.DarfPayment.create!([example_payment(2, true)]) |> hd
    deleted_payment = StarkBank.DarfPayment.delete!(created_payment.id)
    "canceled" = deleted_payment.status
  end

  def example_payment(schedule \\ 0, push_schedule)

  def example_payment(schedule, true) do
    %{example_payment(schedule, false) | scheduled: Date.utc_today() |> Date.add(schedule)}
  end
  
  def example_payment(_, false) do  
    %StarkBank.DarfPayment{
      competence: Date.utc_today() |> Date.add(-2),
      revenue_code: :rand.uniform(9999)
      |> to_string
      |> String.pad_leading(4, "0"),
      nominal_amount: :rand.uniform(1000),
      fine_amount: :rand.uniform(100),
      interest_amount: :rand.uniform(100),
      reference_number: :rand.uniform(1000) |> to_string,
      tax_id: "012.345.678-90",
      description: "description test",
      due: Date.utc_today() |> Date.add(6)
    }
  end
end
