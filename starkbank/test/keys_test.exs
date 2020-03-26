defmodule StarkBankTest.Keys do
  use ExUnit.Case

  @tag :keys
  test "create keys" do
    {private_no_path, public_no_path} = StarkBank.Key.create()

    assert is_binary(private_no_path)
    assert is_binary(public_no_path)

    {private, public} = StarkBank.Key.create("keys")

    assert is_binary(private)
    assert is_binary(public)
  end
end
