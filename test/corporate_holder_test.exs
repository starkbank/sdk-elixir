defmodule StarkBankTest.CorporateHolder do
  use ExUnit.Case

  @tag :corporate_holder
  test "create corporate_holder" do
    {:ok, holders} = StarkBank.CorporateHolder.create([example_corporate_holder()])
    holder = holders |> hd
    assert !is_nil(holder)
  end

  @tag :corporate_holder
  test "create! corporate_holder" do
    holder = StarkBank.CorporateHolder.create!([example_corporate_holder()]) |> hd
    assert !is_nil(holder)
  end

  @tag :corporate_holder
  test "query corporate_holder" do
    StarkBank.CorporateHolder.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_holder
  test "query! corporate_holder" do
    StarkBank.CorporateHolder.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :corporate_holder
  test "query corporate_holder ids" do
    holders_ids_expected =
      StarkBank.CorporateHolder.query(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, holder} -> holder.id end)

    assert length(holders_ids_expected) <= 10

    holders_ids_result =
      StarkBank.CorporateHolder.query(ids: holders_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn {:ok, holder} -> holder.id end)

    assert length(holders_ids_result) <= 10

    holders_ids_expected = Enum.sort(holders_ids_expected)
    holders_ids_result = Enum.sort(holders_ids_result)

    assert holders_ids_expected == holders_ids_result
  end

  @tag :corporate_holder
  test "query! corporate_holder ids" do
    holders_ids_expected =
      StarkBank.CorporateHolder.query!(limit: 10)
      |> Enum.take(100)
      |> Enum.map(fn holder -> holder.id end)

    assert length(holders_ids_expected) <= 10

    holders_ids_result =
      StarkBank.CorporateHolder.query!(ids: holders_ids_expected)
      |> Enum.take(100)
      |> Enum.map(fn holder -> holder.id end)

    assert length(holders_ids_result) <= 10

    holders_ids_expected = Enum.sort(holders_ids_expected)
    holders_ids_result = Enum.sort(holders_ids_result)

    assert holders_ids_expected == holders_ids_result
  end

  @tag :corporate_holder
  test "page corporate_holder" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateHolder.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_holder
  test "page! corporate_holder" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateHolder.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :corporate_holder
  test "get corporate_holder" do
    holder =
      StarkBank.CorporateHolder.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _holder} = StarkBank.CorporateHolder.get(holder.id)
  end

  @tag :corporate_holder
  test "get! corporate_holder" do
    holder =
      StarkBank.CorporateHolder.query!()
      |> Enum.take(1)
      |> hd()

    _holder = StarkBank.CorporateHolder.get!(holder.id)
  end

  @tag :corporate_holder
  test "get! corporate_holder with expand" do
    holder =
      StarkBank.CorporateHolder.query!()
      |> Enum.take(1)
      |> hd()

    expanded_holder = StarkBank.CorporateHolder.get!(holder.id, expand: ["rules"])
    assert !is_nil(expanded_holder.rules)
  end

  @tag :corporate_holder
  test "update and update! corporate_holder" do
    {:ok, [first, second]} =
      StarkBank.CorporateHolder.create([example_corporate_holder(), example_corporate_holder()])

    {:ok, updated_holder} = StarkBank.CorporateHolder.update(first.id, name: "Updated Holder Name")
    assert updated_holder.name == "Updated Holder Name"

    updated_holder! = StarkBank.CorporateHolder.update!(second.id, name: "Updated Holder Name!")
    assert updated_holder!.name == "Updated Holder Name!"
  end

  @tag :corporate_holder
  test "cancel and cancel! corporate_holder" do
    {:ok, [first, second]} =
      StarkBank.CorporateHolder.create([example_corporate_holder(), example_corporate_holder()])

    {:ok, canceled_holder} = StarkBank.CorporateHolder.cancel(first.id)
    assert canceled_holder.status == "canceled"

    canceled_holder! = StarkBank.CorporateHolder.cancel!(second.id)
    assert canceled_holder!.status == "canceled"
  end

  def example_corporate_holder() do
    %StarkBank.CorporateHolder{
      name: "Testerson Holder #{:rand.uniform(1_000_000)}",
      tags: ["Traveler Employee"],
      rules: [
        %StarkBank.CorporateRule{
          name: "General",
          interval: "week",
          amount: 100_000,
          currency_code: "BRL"
        }
      ]
    }
  end
end
