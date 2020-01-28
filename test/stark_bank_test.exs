defmodule StarkBankTest do
  use ExUnit.Case
  doctest StarkBank

  @env :sandbox
  @username "user"
  @email "user@email.com"
  @password "password"

  test "charge" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    # invalidating access token to validate relogin
    Agent.update(credentials, fn map -> Map.put(map, :access_token, "123") end)

    customers =
      Enum.take(
        Stream.cycle([
          %StarkBank.Charge.Structs.CustomerData{
            name: "Arya Stark",
            email: "arya.stark@westeros.com",
            tax_id: "416.631.524-20",
            phone: "(11) 98300-0000",
            tags: ["little girl", "no one", "valar morghulis", "Stark", "test"],
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
            tags: ["night`s watch", "lord commander", "knows nothing", "Stark", "test"],
            address: %StarkBank.Charge.Structs.AddressData{
              street_line_1: "Av. Faria Lima, 1844",
              street_line_2: "CJ 13",
              district: "Itaim Bibi",
              city: "São Paulo",
              state_code: "SP",
              zip_code: "01500-000"
            }
          }
        ]),
        2
      )

    {:ok, customers} = StarkBank.Charge.Customer.post(credentials, customers)

    {:ok, _all_customers} = StarkBank.Charge.Customer.get(credentials)
    {:ok, test_customers} = StarkBank.Charge.Customer.get(credentials, nil, ["Stark"], nil, nil)

    {:ok, _customer} = StarkBank.Charge.Customer.get_by_id(credentials, hd(customers))
    {:ok, customer} = StarkBank.Charge.Customer.get_by_id(credentials, hd(customers).id)

    altered_customer = %{customer | name: "No One"}

    {:ok, altered_customer} = StarkBank.Charge.Customer.put(credentials, altered_customer)

    {:ok, _customers} = StarkBank.Charge.Customer.get(credentials, nil, ["Stark"], nil, 70)
    {:ok, _customers} = StarkBank.Charge.Customer.get(credentials, nil, ["Stark"], nil, 110)

    charges =
      Enum.take(
        Stream.cycle([
          %StarkBank.Charge.Structs.ChargeData{
            amount: 10_000,
            customer: altered_customer.id,
            tags: ["test"]
          },
          %StarkBank.Charge.Structs.ChargeData{
            amount: 100_000,
            customer: "self",
            due_date: Date.utc_today(),
            fine: 10,
            interest: 15,
            overdue_limit: 3,
            tags: ["cash-in", "test"],
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
            amount: 10_000,
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
        ]),
        3
      )

    {:ok, _charges} = StarkBank.Charge.post(credentials, charges)

    {:ok, all_charges} = StarkBank.Charge.get(credentials)

    {:ok, _cash_in_charges} =
      StarkBank.Charge.get(
        credentials,
        "registered",
        ["cash-in"],
        [hd(all_charges).id],
        ["id", "taxId"],
        Date.add(Date.utc_today(), -1),
        Date.add(Date.utc_today(), 1),
        50
      )

    {:ok, pdf} =
      StarkBank.Charge.get_pdf(
        credentials,
        hd(all_charges).id
      )

    {:ok, file} = File.open("test/charge.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)

    {:ok, test_charges} =
      StarkBank.Charge.get(
        credentials,
        "registered",
        ["test"],
        nil,
        ["id", "taxId"]
      )

    {:ok, _deleted_charges} =
      StarkBank.Charge.delete(
        credentials,
        test_charges
      )

    {:ok, _response} = StarkBank.Charge.Customer.delete(credentials, test_customers)

    {:ok, _response} = StarkBank.Charge.Log.get(credentials, [hd(all_charges).id])

    {:ok, charge_logs} =
      StarkBank.Charge.Log.get(credentials, [hd(all_charges).id], ["registered", "cancel"], 30)

    {:ok, _response} = StarkBank.Charge.Log.get_by_id(credentials, hd(charge_logs).id)

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end
end
