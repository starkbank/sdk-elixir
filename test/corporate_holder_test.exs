defmodule StarkBankTest.CorporateHolder do
  use ExUnit.Case
  # alias StarkBankTest.Utils.Faker

  @tag :corporate_holder
  test "create corporate holder test" do
    {:ok, corporate_holder} = StarkBank.CorporateHolder.create(
      [example_corporate_holder()],
      expand: ["rules"]
    )
    corporate_holder = corporate_holder |> Enum.take(1) |> hd

    {:ok, holder} = StarkBank.CorporateHolder.get(corporate_holder.id)

    assert !is_nil(holder.id)
  end

  @tag :corporate_holder
  test "create! corporate holder test" do
    corporate_holder = StarkBank.CorporateHolder.create!(
      [example_corporate_holder()],
      expand: ["rules"]
    )
    corporate_holder = corporate_holder |> Enum.take(1) |> hd

    {:ok, holder} = StarkBank.CorporateHolder.get(corporate_holder.id)

    assert !is_nil(holder.id)
  end

  @tag :corporate_holder
  test "get corporate holder test" do
    holders = StarkBank.CorporateHolder.query!(limit: 5)
    Enum.each(holders, fn holder ->
      {:ok, corporate_holder} = StarkBank.CorporateHolder.get(holder.id)
      assert holder.id == corporate_holder.id
    end)
  end

  @tag :corporate_holder
  test "get! corporate holder test" do
    holders = StarkBank.CorporateHolder.query!(limit: 5)
    Enum.each(holders, fn holder ->
      corporate_holder = StarkBank.CorporateHolder.get!(holder.id)
      assert holder.id == corporate_holder.id
    end)
  end

  @tag :corporate_holder
  test "query corporate holder test" do
    holders = StarkBank.CorporateHolder.query(limit: 10) |> Enum.take(10)

    assert length(holders) <= 10
  end

  @tag :corporate_holder
  test "query! corporate holder test" do
    corporate_holder = StarkBank.CorporateHolder.query!(limit: 10)
      |> Enum.take(10)

    assert length(corporate_holder) <= 10
  end

  @tag :corporate_holder
  test "page corporate holder test" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.CorporateHolder.page/1, 2, limit: 5)

    assert length(ids) <= 10
  end

  @tag :corporate_holder
  test "page! corporate holder test" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.CorporateHolder.page!/1, 2, limit: 5)

    assert length(ids) <= 10
  end

  @tag :corporate_holder
  test "update corporate holder test" do
    {:ok, corporate_holder} = StarkBank.CorporateHolder.create([example_corporate_holder()])
    corporate_holder = corporate_holder |> Enum.take(1) |> hd

    updated_name = new_name()
    {:ok, updated_corporate_holder} = StarkBank.CorporateHolder.update(corporate_holder.id, %{name: updated_name})

    assert updated_corporate_holder.name == updated_name
  end

  @tag :corporate_holder
  test "update! corporate holder test" do
    {:ok, corporate_holder} = StarkBank.CorporateHolder.create([example_corporate_holder()])
    corporate_holder = corporate_holder |> Enum.take(1) |> hd

    updated_name = new_name()
    updated_corporate_holder = StarkBank.CorporateHolder.update!(corporate_holder.id, %{name: updated_name})

    assert updated_corporate_holder.name == updated_name
  end

  @tag :corporate_holder
  test "cancel corporate holder test" do
    corporate_holder =
      StarkBank.CorporateHolder.create!([example_corporate_holder()])
      |> Enum.take(1)
      |> hd

    {:ok, canceled_corporate_holder} = StarkBank.CorporateHolder.cancel(corporate_holder.id)

    assert canceled_corporate_holder.id == corporate_holder.id
  end

  @tag :corporate_holder
  test "cancel! corporate holder test" do
    corporate_holder = StarkBank.CorporateHolder.create!([example_corporate_holder()]) |> Enum.take(1) |> hd
    canceled_corporate_holder = StarkBank.CorporateHolder.cancel!(corporate_holder.id)

    assert canceled_corporate_holder.id == corporate_holder.id
  end

  def example_corporate_holder() do
    %StarkBank.CorporateHolder{
      name: new_name(),
    }
  end

  # @TODO: should it be a Util function?
  def new_name() do
    {_, _, n} = :os.timestamp
    name = "Test_Arya " <> to_string(n) <> " Stark"
    name
  end
end
