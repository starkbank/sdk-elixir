# StarkBank

## Overview

This is a simplified pure Elixir SDK to ease integrations with the Auth and Charge services of the [Stark Bank](https://starkbank.com) [API](https://docs.api.starkbank.com/?version=latest) v1.

## Installation

The package can be installed by adding `stark_bank` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:stark_bank, "~> 1.1.1"}
  ]
end
```

## Usage

### Login

```elixir
{:ok, credentials} = StarkBank.Auth.login(:sandbox, "username", "email@email.com", "password")
```

### Logout

```elixir
{:ok, response} = StarkBank.Auth.logout(credentials)
```

### Create charge customers

```elixir
customers = [
  %StarkBank.Charge.Structs.CustomerData{
    name: "Arya Stark",
    email: "arya.stark@westeros.com",
    tax_id: "416.631.524-20",
    phone: "(11) 98300-0000",
    tags: ["little girl", "no one", "valar morghulis", "Stark"],
    address: %StarkBank.Charge.Structs.AddressData{
      street_line_1: "Av. Faria Lima, 1844",
      street_line_2: "CJ 13",
      district: "Itaim Bibi",
      city: "São Paulo",
      state_code: "SP",
      zip_code: "01500-000"
    }
  },
  %StarkBank.Charge.Structs.CustomerData{
    name: "Jon Snow",
    email: "jon.snow@westeros.com",
    tax_id: "012.345.678-90",
    phone: "(11) 98300-0001",
    tags: ["night`s watch", "lord commander", "knows nothing", "Stark"],
    address: %StarkBank.Charge.Structs.AddressData{
      street_line_1: "Av. Faria Lima, 1844",
      street_line_2: "CJ 13",
      district: "Itaim Bibi",
      city: "São Paulo",
      state_code: "SP",
      zip_code: "01500-000"
    }
  }
]

{:ok, customers} = StarkBank.Charge.Customer.post(credentials, customers)
```

### Get charge customers

```elixir
{:ok, all_customers} = StarkBank.Charge.Customer.get(credentials)
# or
{:ok, customer} = StarkBank.Charge.Customer.get_by_id(credentials, hd(customers).id)
```

### Get charge customers

```elixir
{:ok, all_customers} = StarkBank.Charge.Customer.get(credentials)
# or
{:ok, customer} = StarkBank.Charge.Customer.get_by_id(credentials, hd(customers).id)
```

### Delete charge customers

```elixir
{:ok, response} = StarkBank.Charge.Customer.delete(credentials, customers)
```

### Overwrite charge customers information

```elixir
{:ok, altered_customer} = StarkBank.Charge.Customer.put(credentials, altered_customer)
```

### Create charges

```elixir
charges = [
  %StarkBank.Charge.Structs.ChargeData{
    amount: 100_00,
    customer: altered_customer.id
  },
  %StarkBank.Charge.Structs.ChargeData{
    amount: 1_000_00,
    customer: "self",
    due_date: Date.utc_today(),
    fine: 10,
    interest: 15,
    overdue_limit: 3,
    tags: ["cash-in"],
    descriptions: [
      %StarkBank.Charge.Structs.ChargeDescriptionData{
        text: "part-1",
        amount: 30_000
      },
      %StarkBank.Charge.Structs.ChargeDescriptionData{
        text: "part-2",
        amount: 70_000
      }
    ]
  },
  %StarkBank.Charge.Structs.ChargeData{
    amount: 32_171_32,
    customer: %StarkBank.Charge.Structs.CustomerData{
      name: "Brandon Stark",
      email: "bran.builder@westeros.com",
      tax_id: "123.456.789-09",
      phone: "(11) 98300-0000",
      tags: ["builder", "raven", "Stark", "test"],
      address: %StarkBank.Charge.Structs.AddressData{
        street_line_1: "Av. Faria Lima, 1844",
        street_line_2: "CJ 13",
        district: "Itaim Bibi",
        city: "São Paulo",
        state_code: "SP",
        zip_code: "01500-000"
      }
    },
    tags: ["test"]
  }
]

{:ok, charges} = StarkBank.Charge.post(credentials, charges)
```

### Get created charges

```elixir
{:ok, all_charges} = StarkBank.Charge.get(credentials)
```

### Get charge PDF

```elixir
{:ok, pdf} =
  StarkBank.Charge.get_pdf(
    credentials,
    hd(all_charges).id
  )

{:ok, file} = File.open("charge.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

### Delete created charge

```elixir
StarkBank.Charge.delete(
  credentials,
  [hd(all_charges).id]
)
```

### Get charge logs

```elixir
{:ok, response} = StarkBank.Charge.Log.get(credentials, [hd(all_charges).id])
# or
{:ok, response} = StarkBank.Charge.Log.get_by_id(credentials, hd(charge_logs).id)
```

## Test

Alter @env, @username, @email, @password to your values on test/stark_bank_test.exs. IMPORTANT: Avoid using your production credentials to run this test script, as it will request creations and deletions of charges and related entities.

Afterwards, run:
```sh
mix test --trace
```
