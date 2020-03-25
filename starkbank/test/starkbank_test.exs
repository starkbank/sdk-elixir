defmodule StarkbankTest do
  use ExUnit.Case

  @project_id "5555555555555555"
  @private_key "-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEIN9bTjTvvQUfeQgFaJLh7a7IHEgtpw3LJJOx0d4skFw8oAcGBSuBBAAK\noUQDQgAE6ANVVz6Q5kmbKA/8ZIEhUyDZckjouOTv4Sl5mhWX97WHSxAZlKZ1ZN2t\n/GSTNI8BVCG/oL54f+gdaGc0kT8I8g==\n-----END EC PRIVATE KEY-----\n"


  test "get balance" do
    user = StarkBank.User.project(:sandbox, @project_id, @private_key)
    balance = StarkBank.Balance.get!(user)
    assert !is_nil(balance.amount)
  end

  test "create keys" do
    {_private, _public} = StarkBank.Key.create()
  end
end
