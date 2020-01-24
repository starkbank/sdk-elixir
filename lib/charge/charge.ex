defmodule Charge do
  defmodule Customer do
    def register(credentials, customers) do
      encoded_customers = for customer <- customers, do: Helpers.Customer.encode(customer)
      body = %{customers: encoded_customers}

      {status, response} = Requests.post(credentials, 'charge/customer', body)

      if status == :ok do
        {status, for(customer <- response["customers"], do: Helpers.Customer.decode(customer))}
      else
        {status, response}
      end
    end

    def get(credentials, fields \\ nil, tags \\ nil, taxId \\ nil, limit \\ 100) do
      parameters = [
        fields: Helpers.treat_list(fields),
        tags: Helpers.treat_list(tags),
        taxId: taxId,
        limit: limit
      ]

      {status, response} = Requests.get(credentials, 'charge/customer', parameters)

      if status == :ok do
        {status, for(customer <- response["customers"], do: Helpers.Customer.decode(customer))}
      else
        {status, response}
      end
    end

    def get_by_id(credentials, customer) do
      id = Helpers.extract_id(customer)

      {status, response} = Requests.get(credentials, 'charge/customer/' ++ to_charlist(id))

      if status == :ok do
        {status, Helpers.Customer.decode(response["customer"])}
      else
        {status, response}
      end
    end

    def delete(credentials, customers) do
      ids = for customer <- customers, do: Helpers.extract_id(customer)

      parameters = [
        ids: Helpers.treat_list(ids)
      ]

      {status, response} = Requests.delete(credentials, 'charge/customer', parameters)

      if status == :ok do
        {status, for(customer <- response["customers"], do: Helpers.Customer.decode(customer))}
      else
        {status, response}
      end
    end

    def overwrite(credentials, customer) do
      encoded_customers = Helpers.Customer.encode(customer)
      body = %{customer: encoded_customers}

      {status, response} =
        Requests.put(credentials, 'charge/customer/' ++ to_charlist(customer.id), body)

      if status == :ok do
        {status, Helpers.Customer.decode(response["customer"])}
      else
        {status, response}
      end
    end
  end

  def create(credentials, charges) do
    encoded_charges = for charge <- charges, do: Helpers.Charge.encode(charge)
    body = %{charges: encoded_charges}

    {status, response} = Requests.post(credentials, 'charge', body)

    if status == :ok do
      {status, for(charge <- response["charges"], do: Helpers.Charge.decode(charge))}
    else
      {status, response}
    end
  end
end
