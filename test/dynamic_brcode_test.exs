defmodule StarkBankTest.DynamicBrcode do
  use ExUnit.Case

  @tag :dynamic_brcode
  test "create dynamic_brcode" do
    {:ok, brcodes} = StarkBank.DynamicBrcode.create([example_brcode()])
    brcode = brcodes |> hd
    assert !is_nil(brcode)

  end

  @tag :dynamic_brcode
  test "create! dynamic_brcode" do
    brcode = StarkBank.DynamicBrcode.create!([example_brcode()]) |> hd
    assert !is_nil(brcode)
  end

  @tag :dynamic_brcode
  test "query dynamic_brcode" do
    StarkBank.DynamicBrcode.query(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :dynamic_brcode
  test "query! dynamic_brcode" do
    StarkBank.DynamicBrcode.query!(limit: 101, before: DateTime.utc_now())
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :dynamic_brcode
  test "page dynamic_brcode" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.DynamicBrcode.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :dynamic_brcode
  test "page! dynamic_brcode" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.DynamicBrcode.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :dynamic_brcode
  test "get dynamic_brcode" do
    brcode =
      StarkBank.DynamicBrcode.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _brcode} = StarkBank.DynamicBrcode.get(brcode.id)
  end

  @tag :dynamic_brcode
  test "get! dynamic_brcode" do
    brcode =
      StarkBank.DynamicBrcode.query!()
      |> Enum.take(1)
      |> hd()

    _brcode = StarkBank.DynamicBrcode.get!(brcode.id)
  end

  def example_brcode() do
    %StarkBank.DynamicBrcode{
      amount: 400000,
      expiration: 123456789,
      tags: [
        "War supply",
        "DynamicBrcode #1234"
      ]
    }
  end

end
