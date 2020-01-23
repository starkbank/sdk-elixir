defmodule Charge do
  defmodule Customer do
    def register(credentials, customers) do
      encoded_customers = for customer <- customers, do: encode_customer(customer)
      body = %{customers: encoded_customers}

      Requests.post(credentials, 'charge/customer', body)
    end

    def get(credentials, fields \\ nil, tags \\ nil, taxId \\ nil, limit \\ 100) do
      parameters = [
        fields: treat_list(fields),
        tags: treat_list(tags),
        taxId: taxId,
        limit: limit
      ]

      {status, response} = Requests.get(credentials, 'charge/customer', parameters)

      if status == :ok do
        {status, for(customer <- response["customers"], do: decode_customer(customer))}
      else
        {status, response}
      end
    end

    def delete(credentials, customers) do
      ids = for customer <- customers, do: extract_id_from_customer(customer)

      parameters = [
        ids: ids
      ]

      {status, response} = Requests.del(credentials, 'charge/customer', parameters)
    end

    defp treat_list(list) when list == nil do
      nil
    end

    defp treat_list(list) do
      Enum.join(list, ",")
    end

    defp encode_customer(customer) do
      address = customer.address

      %{
        name: customer.name,
        email: customer.email,
        taxId: customer.tax_id,
        phone: customer.phone,
        tags: customer.tags,
        address: %{
          streetLine1: address.street_line_1,
          streetLine2: address.street_line_2,
          district: address.district,
          city: address.city,
          stateCode: address.state_code,
          zipCode: address.zip_code
        }
      }
    end

    defp decode_customer(customer) do
      charge_count = customer["chargeCount"]
      address = customer["address"]

      %CustomerData{
        name: customer["name"],
        email: customer["email"],
        tax_id: customer["taxId"],
        phone: customer["phone"],
        id: customer["id"],
        charge_count: %ChargeCount{
          overdue: charge_count["overdue"],
          pending: charge_count["pending"]
        },
        address: %AddressData{
          street_line_1: address["streetLine1"],
          street_line_2: address["streetLine2"],
          district: address["district"],
          city: address["city"],
          state_code: address["stateCode"],
          zip_code: address["zipCode"]
        },
        tags: customer["tags"]
      }
    end

    defp extract_id_from_customer(customer) when is_binary(customer) or is_integer(customer) do
      customer
    end

    defp extract_id_from_customer(customer) do
      customer.id
    end
  end
end
