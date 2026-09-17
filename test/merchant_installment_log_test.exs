defmodule StarkBankTest.MerchantInstallmentLog do
  use ExUnit.Case

  @tag :merchant_installment_log
  test "query merchant_installment log" do
    StarkBank.MerchantInstallment.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_installment_log
  test "query! merchant_installment log" do
    StarkBank.MerchantInstallment.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_installment_log
  test "query! merchant_installment log with filters" do
    installment =
      StarkBank.MerchantInstallment.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.MerchantInstallment.Log.query!(limit: 1, installment_ids: [installment.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :merchant_installment_log
  test "page merchant_installment log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.MerchantInstallment.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_installment_log
  test "page! merchant_installment log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.MerchantInstallment.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_installment_log
  test "get merchant_installment log" do
    log =
      StarkBank.MerchantInstallment.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.MerchantInstallment.Log.get(log.id)
  end

  @tag :merchant_installment_log
  test "get! merchant_installment log" do
    log =
      StarkBank.MerchantInstallment.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.MerchantInstallment.Log.get!(log.id)
  end
end
