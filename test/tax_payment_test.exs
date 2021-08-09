defmodule StarkBankTest.TaxPayment do
  use ExUnit.Case
  
  @tag :tax_payment
  test "create tax payment" do
    {:ok, payments} = StarkBank.TaxPayment.create([example_payment(2, true)])
    payment = payments |> hd
    assert !is_nil(payment)
  end
  
  @tag :tax_payment
  test "create! tax payment" do
    payment = StarkBank.TaxPayment.create!([example_payment(2, true)]) |> hd
    assert !is_nil(payment)
  end
  
  @tag :tax_payment
  test "query tax payment" do
    StarkBank.TaxPayment.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end
  
  @tag :tax_payment
  test "query! tax payment" do
    StarkBank.TaxPayment.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end
  
  @tag :tax_payment
  test "query payment ids" do
    payments_ids_expected =
    StarkBank.TaxPayment.query(limit: 10)
    |> Enum.take(100)
    |> Enum.map(fn {:ok, payment} -> payment.id end)
  
    assert length(payments_ids_expected) <= 10
  
    payments_ids_result =
    StarkBank.TaxPayment.query(ids: payments_ids_expected)
    |> Enum.take(100)
    |> Enum.map(fn {:ok, payment} -> payment.id end)
  
    assert length(payments_ids_result) <= 10
  
    payments_ids_expected = Enum.sort(payments_ids_expected)
    payments_ids_result = Enum.sort(payments_ids_result)
  
    assert payments_ids_expected == payments_ids_result
  end
  
  @tag :tax_payment
  test "query! payment ids" do
    payments_ids_expected =
    StarkBank.TaxPayment.query!(limit: 10)
    |> Enum.take(100)
    |> Enum.map(fn payment -> payment.id end)
  
    assert length(payments_ids_expected) <= 10
  
    payments_ids_result =
    StarkBank.TaxPayment.query!(ids: payments_ids_expected)
    |> Enum.take(100)
    |> Enum.map(fn payment -> payment.id end)
  
    assert length(payments_ids_result) <= 10
  
    payments_ids_expected = Enum.sort(payments_ids_expected)
    payments_ids_result = Enum.sort(payments_ids_result)
  
    assert payments_ids_expected == payments_ids_result
  end
  
  @tag :tax_payment
  test "page tax payment" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.TaxPayment.page/1, 2, limit: 5)
    assert length(ids) == 10
  end
  
  @tag :tax_payment
  test "page! tax payment" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.TaxPayment.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end
  
  @tag :tax_payment
  test "get tax payment" do
    payment =
    StarkBank.TaxPayment.query!()
    |> Enum.take(1)
    |> hd()
  
    {:ok, _payment} = StarkBank.TaxPayment.get(payment.id)
  end
  
  @tag :tax_payment
  test "get! tax payment" do
    payment =
    StarkBank.TaxPayment.query!()
    |> Enum.take(1)
    |> hd()
  
    _payment = StarkBank.TaxPayment.get!(payment.id)
  end

  @tag :tax_payment
  test "pdf tax payment" do
    payment =
    StarkBank.TaxPayment.query!(status: "processing")
    |> Enum.take(1)
    |> hd()
  
    {:ok, _pdf} = StarkBank.TaxPayment.pdf(payment.id)
  end
  
  @tag :tax_payment
  test "pdf! tax payment" do
    payment =
    StarkBank.TaxPayment.query!(status: "processing")
    |> Enum.take(1)
    |> hd()
  
    pdf = StarkBank.TaxPayment.pdf!(payment.id)
    file = File.open!("tmp/tax-payment.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)
  end
  
  @tag :tax_payment
  test "delete tax payment" do
    created_payment =
    StarkBank.TaxPayment.create!([example_payment(2, true)]) |> hd
    {:ok, deleted_payment} = StarkBank.TaxPayment.delete(created_payment.id)
    "canceled" = deleted_payment.status
  end
  
  @tag :tax_payment
  test "delete! tax payment" do
    created_payment =
    StarkBank.TaxPayment.create!([example_payment(2, true)]) |> hd
    deleted_payment = StarkBank.TaxPayment.delete!(created_payment.id)
    "canceled" = deleted_payment.status
  end

  def example_payment(schedule \\ 0, push_schedule)

  def example_payment(schedule, true) do
    %{example_payment(schedule, false) | scheduled: Date.utc_today() |> Date.add(schedule)}
  end
  
  def example_payment(_, false) do
    bar_code_core =
    :rand.uniform(100_000)
    |> to_string
    |> String.pad_leading(8, "0")
  
    %StarkBank.TaxPayment{
    bar_code: "8566000" <> bar_code_core <> "00640074119002551100010601813",
    description: "paying taxes",
    tags: ["test1", "test2", "test3"]
    }
  end
end
