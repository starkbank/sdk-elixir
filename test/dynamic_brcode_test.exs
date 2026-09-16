defmodule StarkBankTest.DynamicBrcode do
  use ExUnit.Case

  @tag :dynamic_brcode
  test "create dynamic brcode" do
    {:ok, brcodes} = StarkBank.DynamicBrcode.create([example_dynamic_brcode()])
    brcode = brcodes |> hd
    assert !is_nil(brcode)
    assert brcode.rules == [%{"key" => "allowedTaxIds", "value" => ["012.345.678-90"]}]
  end

  @tag :dynamic_brcode
  test "create! dynamic brcode" do
    brcode = StarkBank.DynamicBrcode.create!([example_dynamic_brcode()]) |> hd
    assert !is_nil(brcode)
  end

  @tag :dynamic_brcode
  test "query dynamic brcode" do
    StarkBank.DynamicBrcode.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :dynamic_brcode
  test "query! dynamic brcode" do
    StarkBank.DynamicBrcode.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :dynamic_brcode
  test "query dynamic brcode uuids" do
    brcodes_uuids_expected =
      StarkBank.DynamicBrcode.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, brcode} -> brcode.uuid end)

    assert length(brcodes_uuids_expected) <= 10

    brcodes_uuids_result =
      StarkBank.DynamicBrcode.query(uuids: brcodes_uuids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, brcode} -> brcode.uuid end)

    assert length(brcodes_uuids_result) <= 10

    brcodes_uuids_expected = Enum.sort(brcodes_uuids_expected)
    brcodes_uuids_result = Enum.sort(brcodes_uuids_result)

    assert brcodes_uuids_expected == brcodes_uuids_result
  end

  @tag :dynamic_brcode
  test "query! dynamic brcode uuids" do
    brcodes_uuids_expected =
      StarkBank.DynamicBrcode.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn brcode -> brcode.uuid end)

    assert length(brcodes_uuids_expected) <= 10

    brcodes_uuids_result =
      StarkBank.DynamicBrcode.query!(uuids: brcodes_uuids_expected)
      |> Enum.take(100)
      |> Enum.map(fn brcode -> brcode.uuid end)

    assert length(brcodes_uuids_result) <= 10

    brcodes_uuids_expected = Enum.sort(brcodes_uuids_expected)
    brcodes_uuids_result = Enum.sort(brcodes_uuids_result)

    assert brcodes_uuids_expected == brcodes_uuids_result
  end

  @tag :dynamic_brcode
  test "page dynamic brcode" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.DynamicBrcode.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :dynamic_brcode
  test "page! dynamic brcode" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.DynamicBrcode.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :dynamic_brcode
  test "get dynamic brcode" do
    brcode =
      StarkBank.DynamicBrcode.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _brcode} = StarkBank.DynamicBrcode.get(brcode.uuid)
  end

  @tag :dynamic_brcode
  test "get! dynamic brcode" do
    brcode =
      StarkBank.DynamicBrcode.query!()
      |> Enum.take(1)
      |> hd()

    _brcode = StarkBank.DynamicBrcode.get!(brcode.uuid)
  end

  def example_dynamic_brcode() do
    %StarkBank.DynamicBrcode{
      amount: :rand.uniform(100_000),
      display_description: "loading a random account",
      tags: ["elixir", "sdk"],
      rules: [%{"key" => "allowedTaxIds", "value" => ["012.345.678-90"]}]
    }
  end
end
