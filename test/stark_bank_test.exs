defmodule StarkBankTest do
  use ExUnit.Case
  doctest StarkBank

  @env :sandbox
  @username "user"
  @email "user@email.com"
  @password "password"

  test "registers customer" do
    {:ok, credentials} = Auth.login(@env, @username, @email, @password)

    customers = [
      %CustomerData{
        name: "Arya Stark",
        email: "arya.stark@westeros.com",
        tax_id: "526.883.040-62",
        phone: "(11) 98300-0000",
        tags: ["little girl", "no one", "valar morghulis"],
        address: %AddressData{
          street_line_1: "Av. Faria Lima, 1844",
          street_line_2: "CJ 13",
          district: "Itaim Bibi",
          city: "Sao Paulo",
          state_code: "SP",
          zip_code: "01500-000"
        }
      }
    ]

    {:ok, _response} = Charge.Customer.register(credentials, customers)
  end

  test "get customers" do
    {:ok, credentials} = Auth.login(@env, @username, @email, @password)

    {:ok, customers} =
      Charge.Customer.get(credentials, nil, ["little girl"], "526.883.040-62", 100)

    IO.inspect(customers)
  end

  test "delete customers" do
    {:ok, credentials} = Auth.login(@env, @username, @email, @password)

    {:ok, customers} =
      Charge.Customer.get(credentials, nil, ["little girl"], "526.883.040-62", 100)

    {:ok, response} = Charge.Customer.delete(credentials, customers)

    IO.inspect(response)
  end
end
