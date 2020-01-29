defmodule StarkBankTest do
  use ExUnit.Case

  @env :sandbox
  @username "user"
  @email "user@email.com"
  @password "password"

  @charge_customer_post_load 2
  @charge_post_load 3

  test "auth-session" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)
    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "auth-relogin" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    # invalidating access token to validate relogin
    Agent.update(credentials, fn map -> Map.put(map, :access_token, "123") end)

    {:ok, _response} = StarkBank.Charge.get(credentials, limit: 1)

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-customer-post" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

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
        @charge_customer_post_load
      )

    {:ok, posted_customers} = StarkBank.Charge.Customer.post(credentials, customers)

    assert length(customers) == length(posted_customers)

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-customer-get" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, _all_customers} = StarkBank.Charge.Customer.get(credentials)

    {:ok, _70_customers} = StarkBank.Charge.Customer.get(credentials, tags: ["Stark"], limit: 70)

    {:ok, _110_customers} =
      StarkBank.Charge.Customer.get(credentials, tags: ["Stark"], limit: 110)

    {:ok, _test_customers} =
      StarkBank.Charge.Customer.get(
        credentials,
        fields: ["name", "tax_id"],
        tags: ["test"],
        tax_id: "012.345.678-90"
      )

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-customer-get_by_id" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, one_customer} =
      StarkBank.Charge.Customer.get(
        credentials,
        limit: 1
      )

    one_customer = hd(one_customer)

    {:ok, customer_from_struct} = StarkBank.Charge.Customer.get_by_id(credentials, one_customer)
    {:ok, customer_from_id} = StarkBank.Charge.Customer.get_by_id(credentials, one_customer.id)

    assert one_customer == customer_from_struct
    assert one_customer == customer_from_id

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-customer-put" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, one_customer} =
      StarkBank.Charge.Customer.get(
        credentials,
        tags: ["test"],
        limit: 1
      )

    one_customer = hd(one_customer)

    altered_customer = %{one_customer | name: "No One"}

    {:ok, received_altered_customer} =
      StarkBank.Charge.Customer.put(credentials, altered_customer)

    assert altered_customer == received_altered_customer

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-post" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, one_customer} =
      StarkBank.Charge.Customer.get(
        credentials,
        tags: ["test"],
        limit: 1
      )

    one_customer = hd(one_customer)

    charges =
      Enum.take(
        Stream.cycle([
          %StarkBank.Charge.Structs.ChargeData{
            amount: 10_000,
            customer: one_customer.id,
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
        @charge_post_load
      )

    {:ok, posted_charges} = StarkBank.Charge.post(credentials, charges)

    assert length(charges) == length(posted_charges)

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-get" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, all_charges} = StarkBank.Charge.get(credentials)

    {:ok, _filtered_charges} =
      StarkBank.Charge.get(
        credentials,
        status: "registered",
        tags: ["cash-in"],
        ids: [hd(all_charges).id],
        fields: ["id", "tax_id"],
        filter_after: Date.add(Date.utc_today(), -1),
        filter_before: Date.add(Date.utc_today(), 1),
        limit: 50
      )

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-get-pdf" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, one_charge} =
      StarkBank.Charge.get(
        credentials,
        status: "registered",
        tags: ["test"],
        fields: ["id"],
        limit: 1
      )

    {:ok, pdf} =
      StarkBank.Charge.get_pdf(
        credentials,
        hd(one_charge).id
      )

    {:ok, file} = File.open("test/charge.pdf", [:write])
    IO.binwrite(file, pdf)
    File.close(file)

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-delete" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, test_charges} =
      StarkBank.Charge.get(
        credentials,
        status: "registered",
        tags: ["test"]
      )

    {:ok, _deleted_charges} =
      StarkBank.Charge.delete(
        credentials,
        test_charges
      )

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-customer-delete" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, test_customers} =
      StarkBank.Charge.Customer.get(
        credentials,
        fields: ["id"],
        tags: ["test"]
      )

    {:ok, _response} = StarkBank.Charge.Customer.delete(credentials, test_customers)

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-log-get" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, one_charge} =
      StarkBank.Charge.get(
        credentials,
        tags: ["test"],
        fields: ["id"],
        limit: 1
      )

    {:ok, _response} = StarkBank.Charge.Log.get(credentials, [hd(one_charge)])

    {:ok, _charge_logs} =
      StarkBank.Charge.Log.get(credentials, [hd(one_charge).id],
        events: ["registered", "cancel"],
        limit: 30
      )

    {:ok, _charge_logs} =
      StarkBank.Charge.Log.get(credentials, [hd(one_charge).id],
        events: ["registered", "cancel"],
        limit: 130
      )

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end

  test "charge-log-get_by_id" do
    {:ok, credentials} = StarkBank.Auth.login(@env, @username, @email, @password)

    {:ok, one_charge} =
      StarkBank.Charge.get(
        credentials,
        tags: ["test"],
        fields: ["id"],
        limit: 1
      )

    {:ok, charge_logs} = StarkBank.Charge.Log.get(credentials, [hd(one_charge)])

    {:ok, _charge_log} = StarkBank.Charge.Log.get_by_id(credentials, hd(charge_logs).id)

    {:ok, _response} = StarkBank.Auth.logout(credentials)
  end
end
