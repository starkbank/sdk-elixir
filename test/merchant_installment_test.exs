defmodule StarkBankTest.MerchantInstallment do
  use ExUnit.Case

  @tag :merchant_installment
  test "query merchant_installment" do
    StarkBank.MerchantInstallment.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_installment
  test "query! merchant_installment" do
    StarkBank.MerchantInstallment.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :merchant_installment
  test "query merchant_installment ids" do
    installments_ids_expected =
      StarkBank.MerchantInstallment.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, installment} -> installment.id end)

    assert length(installments_ids_expected) <= 10

    installments_ids_result =
      StarkBank.MerchantInstallment.query(ids: installments_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, installment} -> installment.id end)

    assert length(installments_ids_result) <= 10

    installments_ids_expected = Enum.sort(installments_ids_expected)
    installments_ids_result = Enum.sort(installments_ids_result)

    assert installments_ids_expected == installments_ids_result
  end

  @tag :merchant_installment
  test "query! merchant_installment ids" do
    installments_ids_expected =
      StarkBank.MerchantInstallment.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn installment -> installment.id end)

    assert length(installments_ids_expected) <= 10

    installments_ids_result =
      StarkBank.MerchantInstallment.query!(ids: installments_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn installment -> installment.id end)

    assert length(installments_ids_result) <= 10

    installments_ids_expected = Enum.sort(installments_ids_expected)
    installments_ids_result = Enum.sort(installments_ids_result)

    assert installments_ids_expected == installments_ids_result
  end

  @tag :merchant_installment
  test "query! merchant_installment with purchase_ids filter" do
    installment =
      StarkBank.MerchantInstallment.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.MerchantInstallment.query!(limit: 1, purchase_ids: [installment.purchase_id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) >= 1 end).()
  end

  @tag :merchant_installment
  test "page merchant_installment" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.MerchantInstallment.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_installment
  test "page! merchant_installment" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.MerchantInstallment.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :merchant_installment
  test "get merchant_installment" do
    installment =
      StarkBank.MerchantInstallment.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _installment} = StarkBank.MerchantInstallment.get(installment.id)
  end

  @tag :merchant_installment
  test "get! merchant_installment" do
    installment =
      StarkBank.MerchantInstallment.query!()
      |> Enum.take(1)
      |> hd()

    _installment = StarkBank.MerchantInstallment.get!(installment.id)
  end
end
