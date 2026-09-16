defmodule StarkBankTest.CardMethod do
  use ExUnit.Case

  @tag :card_method
  test "query card_method" do
    StarkBank.CardMethod.query(search: "token")
    |> Enum.take(10)
    |> (fn list -> assert length(list) > 0 end).()
  end

  @tag :card_method
  test "query! card_method" do
    methods = StarkBank.CardMethod.query!(search: "token") |> Enum.take(10)
    assert length(methods) > 0

    assert Enum.all?(methods, fn method -> !is_nil(method.code) end)
  end
end
