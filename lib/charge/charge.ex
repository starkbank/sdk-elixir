defmodule StarkBank.Charge do
  @moduledoc """
  used to create and consult charges;

  submodules:
  - StarkBank.Customer: Used to create and consult charge customers;
  - StarkBank.Log: Used to consult charge logs;
  """

  alias StarkBank.Utils.Helpers, as: Helpers
  alias StarkBank.Utils.Requests, as: Requests
  alias StarkBank.Charge.Helpers, as: ChargeHelpers

  defmodule Customer do
    @moduledoc """
    used to create, update and delete charge customers;
    """

    @doc """
    registers a new customer that can be linked with charge emissions

    parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customers: list of StarkBank.Charge.Structs.CustomerData;
    """
    def post(credentials, customers) do
      registrations =
        for partial_customers <- Helpers.chunk_list_by_max_limit(customers),
            do: partial_post(credentials, partial_customers)

      Helpers.flatten_responses(registrations)
    end

    defp partial_post(credentials, customers) do
      encoded_customers = for customer <- customers, do: ChargeHelpers.Customer.encode(customer)
      body = %{customers: encoded_customers}

      {response_status, response} = Requests.post(credentials, 'charge/customer', body)

      if response_status != :ok do
        {response_status, response}
      else
        {response_status,
         for(customer <- response["customers"], do: ChargeHelpers.Customer.decode(customer))}
      end
    end

    @doc """
    gets charge customers data according to informed parameters

    parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - fields [list of strings]: list of customer fields that should be retrieved from the API;
    - tags [list of strings]: filters customers by the provided tags;
    - tax_id [string]: filters customers by tax ID;
    - limit [int]: maximum results retrieved;
    """
    def get(credentials, fields \\ nil, tags \\ nil, tax_id \\ nil, limit \\ nil) do
      recursive_get(
        credentials,
        Helpers.snake_to_camel_list_of_strings(fields),
        Helpers.lowercase_list_of_strings(tags),
        tax_id,
        limit,
        nil
      )
    end

    defp recursive_get(credentials, fields, tags, tax_id, limit, cursor) do
      {response_status, response} = partial_get(credentials, fields, tags, tax_id, limit, cursor)

      if response_status != :ok do
        {response_status, response}
      else
        %{cursor: new_cursor, customers: customers} = response

        if is_nil(new_cursor) or Helpers.limit_below_maximum?(limit) do
          {response_status, response[:customers]}
        else
          {new_response_status, new_response} =
            recursive_get(
              credentials,
              fields,
              tags,
              tax_id,
              Helpers.get_recursive_limit(limit),
              new_cursor
            )

          if new_response_status != :ok do
            {new_response_status, new_response}
          else
            {new_response_status, customers ++ new_response}
          end
        end
      end
    end

    defp partial_get(
           credentials,
           fields,
           tags,
           tax_id,
           limit,
           cursor
         ) do
      parameters = [
        fields: Helpers.list_to_url_arg(fields),
        tags: Helpers.list_to_url_arg(tags),
        taxId: tax_id,
        limit: Helpers.truncate_limit(limit),
        cursor: cursor
      ]

      {response_status, response} = Requests.get(credentials, 'charge/customer', parameters)

      if response_status != :ok do
        {response_status, response}
      else
        {
          response_status,
          %{
            cursor: response["cursor"],
            customers:
              for(customer <- response["customers"], do: ChargeHelpers.Customer.decode(customer))
          }
        }
      end
    end

    @doc """
    gets the charge customer with the specified ID

    parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customer [string]: charge customer ID, e.g.: "6307371336859648";
    """
    def get_by_id(credentials, customer) do
      id = Helpers.extract_id(customer)

      {response_status, response} =
        Requests.get(credentials, 'charge/customer/' ++ to_charlist(id))

      if response_status != :ok do
        {response_status, response}
      else
        {response_status, ChargeHelpers.Customer.decode(response["customer"])}
      end
    end

    @doc """
    deletes the charge customer with the specified ID

    parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customers [list of strings or list of StarkBank.Charge.Structs.CustomerData]: charge customer data or IDs, e.g.: ["6307371336859648"];
    """
    def delete(credentials, customers) do
      deletions =
        for partial_customers <- Helpers.chunk_list_by_max_limit(customers),
            do: partial_delete(credentials, partial_customers)

      Helpers.flatten_responses(deletions)
    end

    defp partial_delete(credentials, customers) do
      parameters = [
        ids: Helpers.treat_nullable_id_or_struct_list(customers)
      ]

      {response_status, response} = Requests.delete(credentials, 'charge/customer', parameters)

      if response_status != :ok do
        {response_status, response}
      else
        {response_status,
         for(customer <- response["customers"], do: ChargeHelpers.Customer.decode(customer))}
      end
    end

    @doc """
    overwrites the charge customer with the specified ID

    parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customer [StarkBank.Charge.Structs.CustomerData]: charge customer data;
    """
    def put(credentials, customer) do
      encoded_customers = ChargeHelpers.Customer.encode(customer)
      body = %{customer: encoded_customers}

      {response_status, response} =
        Requests.put(credentials, 'charge/customer/' ++ to_charlist(customer.id), body)

      if response_status != :ok do
        {response_status, response}
      else
        {response_status, ChargeHelpers.Customer.decode(response["customer"])}
      end
    end
  end

  defmodule Log do
    @moduledoc """
    used to consult charge events;
    """

    @doc """
    gets the charge logs according to the provided parameters

    parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - charge_ids [list of strings or list of StarkBank.Charge.Structs.ChargeData]: charge IDs or charge structs, e.g.: ["5618308887871488"];
    - events [list of string]: filter by log events, namely: "register", "registered", "overdue", "updated", "canceled", "failed", "paid" or "bank";
    - limit [int]: maximum results retrieved;
    """
    def get(credentials, charge_ids, events \\ nil, limit \\ nil) do
      recursive_get(
        credentials,
        Helpers.treat_nullable_id_or_struct_list(charge_ids),
        Helpers.list_to_url_arg(events),
        limit,
        nil
      )
    end

    defp recursive_get(credentials, charge_ids, events, limit, cursor) do
      {response_status, response} = partial_get(credentials, charge_ids, events, limit, cursor)

      if response_status != :ok do
        {response_status, response}
      else
        %{cursor: new_cursor, logs: logs} = response

        if is_nil(new_cursor) or Helpers.limit_below_maximum?(limit) do
          {response_status, response[:logs]}
        else
          {new_response_status, new_response} =
            recursive_get(
              credentials,
              charge_ids,
              events,
              Helpers.get_recursive_limit(limit),
              new_cursor
            )

          if new_response_status != :ok do
            {new_response_status, new_response}
          else
            {new_response_status, logs ++ new_response}
          end
        end
      end
    end

    defp partial_get(credentials, charge_ids, events, limit, cursor) do
      parameters = [
        chargeIds: charge_ids,
        events: events,
        limit: limit,
        cursor: cursor
      ]

      {response_status, response} = Requests.get(credentials, 'charge/log', parameters)

      if response_status != :ok do
        {response_status, response}
      else
        {
          response_status,
          %{
            cursor: response["cursor"],
            logs: for(log <- response["logs"], do: ChargeHelpers.ChargeLog.decode(log))
          }
        }
      end
    end

    @doc """
    gets the charge log specified by the provided ID;

    parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - charge_log_id [string or StarkBank.Charge.Structs.ChargeLogData]: charge log ID or struct, e.g.: "6743665380687872";
    """
    def get_by_id(credentials, charge_log_id) do
      id = Helpers.extract_id(charge_log_id)

      {response_status, response} = Requests.get(credentials, 'charge/log/' ++ to_charlist(id))

      if response_status != :ok do
        {response_status, response}
      else
        {response_status, ChargeHelpers.ChargeLog.decode(response["log"])}
      end
    end
  end

  @doc """
  creates a new charge

  parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - charges [list of StarkBank.Charge.Structs.ChargeData]: charge structs;
  """
  def post(credentials, charges) do
    creations =
      for partial_charges <- Helpers.chunk_list_by_max_limit(charges),
          do: partial_post(credentials, partial_charges)

    Helpers.flatten_responses(creations)
  end

  defp partial_post(credentials, charges) do
    {filled_charges, temp_customer_ids} = fill_charges_with_temp_customers(credentials, charges)

    encoded_charges = for charge <- filled_charges, do: ChargeHelpers.Charge.encode(charge)
    body = %{charges: encoded_charges}

    {response_status, response} = Requests.post(credentials, 'charge', body)

    if length(temp_customer_ids) > 0 do
      Customer.delete(credentials, temp_customer_ids)
    end

    if response_status != :ok do
      {response_status, response}
    else
      {response_status,
       for(charge <- response["charges"], do: ChargeHelpers.Charge.decode(charge))}
    end
  rescue
    e in MatchError -> {:error, e}
  end

  defp fill_charges_with_temp_customers(credentials, charges) do
    charges_with_customer_ids =
      for charge <- charges, !is_nil(Helpers.extract_id(charge.customer)), do: charge

    charges_without_customer_ids =
      for charge <- charges, is_nil(Helpers.extract_id(charge.customer)), do: charge

    temp_customers = create_temp_customers(credentials, charges_without_customer_ids)

    charges_with_temp_customers =
      for charge <- charges_without_customer_ids,
          do: fill_charge_customer_id(charge, temp_customers)

    {
      charges_with_customer_ids ++ charges_with_temp_customers,
      for(customer <- temp_customers, do: customer.id)
    }
  end

  defp create_temp_customers(credentials, charges) when length(charges) > 0 do
    {:ok, temp_customers} =
      Customer.post(
        credentials,
        for(charge <- charges, do: charge.customer)
      )

    temp_customers
  end

  defp create_temp_customers(_credentials, _charges) do
    []
  end

  defp fill_charge_customer_id(charge, temp_customers) do
    %StarkBank.Charge.Structs.ChargeData{
      charge
      | customer: find_matching_customer(charge.customer, temp_customers)
    }
  end

  defp find_matching_customer(base_customer, [temp_customer | other_temp_customers]) do
    if customers_match?(base_customer, temp_customer) do
      temp_customer
    else
      find_matching_customer(base_customer, other_temp_customers)
    end
  end

  defp find_matching_customer(_base_customer, []) do
    throw("SDK logic failed to locate temporary customer, please contact support")
  end

  defp customers_match?(base_customer, comp_customer) do
    base_address = base_customer.address
    comp_address = comp_customer.address

    Helpers.nullable_fields_match?(base_customer.name, comp_customer.name) and
      Helpers.nullable_fields_match?(base_customer.email, comp_customer.email) and
      Helpers.nullable_fields_match?(base_customer.tax_id, comp_customer.tax_id) and
      Helpers.nullable_fields_match?(base_customer.phone, comp_customer.phone) and
      Helpers.nullable_fields_match?(
        Helpers.lowercase_list_of_strings(base_customer.tags),
        comp_customer.tags
      ) and
      Helpers.nullable_fields_match?(base_address.street_line_1, comp_address.street_line_1) and
      Helpers.nullable_fields_match?(base_address.street_line_2, comp_address.street_line_2) and
      Helpers.nullable_fields_match?(base_address.district, comp_address.district) and
      Helpers.nullable_fields_match?(base_address.city, comp_address.city) and
      Helpers.nullable_fields_match?(base_address.state_code, comp_address.state_code) and
      Helpers.nullable_fields_match?(base_address.zip_code, comp_address.zip_code)
  end

  @doc """
  gets charges according to the provided parameters

  parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - status [string]: filters specified charge status, namely: "created", "registered", "paid", "overdue", "canceled" or "failed";
  - tags [list of strings]: filters charges by tags, e.g.: ["client1", "cash-in"];
  - ids [list of strings or StarkBank.Charge.Structs.ChargeData]: charge IDs or data structs to be retrieved, e.g.: ["5718322100305920", "5705293853884416"];
  - fields [list of strings]: selects charge data fields on API response, e.g.: ["id", "amount", "status"];
  - filter_after [date or "%Y-%m-%d"]: only gets charges created after this date, e.g.: "2019-04-01";
  - filter_before [date or "%Y-%m-%d"]: only gets charges created before this date, e.g.: "2019-05-01";
  - limit [int]: maximum results retrieved;
  """
  def get(
        credentials,
        status \\ nil,
        tags \\ nil,
        ids \\ nil,
        fields \\ nil,
        filter_after \\ nil,
        filter_before \\ nil,
        limit \\ nil
      ) do
    recursive_get(
      credentials,
      status,
      Helpers.lowercase_list_of_strings(tags),
      ids,
      Helpers.snake_to_camel_list_of_strings(fields),
      filter_after,
      filter_before,
      limit,
      nil
    )
  end

  defp recursive_get(
         credentials,
         status,
         tags,
         ids,
         fields,
         filter_after,
         filter_before,
         limit,
         cursor
       ) do
    {response_status, response} =
      partial_get(
        credentials,
        status,
        tags,
        ids,
        fields,
        filter_after,
        filter_before,
        limit,
        cursor
      )

    if response_status != :ok do
      {response_status, response}
    else
      %{cursor: new_cursor, charges: charges} = response

      if is_nil(new_cursor) or Helpers.limit_below_maximum?(limit) do
        {response_status, response[:charges]}
      else
        {new_response_status, new_response} =
          recursive_get(
            credentials,
            status,
            tags,
            ids,
            fields,
            filter_after,
            filter_before,
            Helpers.get_recursive_limit(limit),
            new_cursor
          )

        if new_response_status != :ok do
          {new_response_status, new_response}
        else
          {new_response_status, charges ++ new_response}
        end
      end
    end
  end

  defp partial_get(
         credentials,
         status,
         tags,
         ids,
         fields,
         filter_after,
         filter_before,
         limit,
         cursor
       ) do
    parameters = [
      status: status,
      tags: Helpers.list_to_url_arg(tags),
      ids: Helpers.treat_nullable_id_or_struct_list(ids),
      fields: Helpers.list_to_url_arg(fields),
      after: Helpers.date_to_string(filter_after),
      before: Helpers.date_to_string(filter_before),
      limit: limit,
      cursor: cursor
    ]

    {response_status, response} = Requests.get(credentials, 'charge', parameters)

    if response_status != :ok do
      {response_status, response}
    else
      {
        response_status,
        %{
          cursor: response["cursor"],
          charges: for(charge <- response["charges"], do: ChargeHelpers.Charge.decode(charge))
        }
      }
    end
  end

  @doc """
  deletes the specified charges

  parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - ids [list of strings or StarkBank.Charge.Structs.ChargeData]: charge IDs or data structs to be deleted, e.g.: ["5718322100305920", "5705293853884416"];
  """
  def delete(credentials, ids) do
    deletions =
      for partial_ids <- Helpers.chunk_list_by_max_limit(ids),
          do: partial_delete(credentials, partial_ids)

    Helpers.flatten_responses(deletions)
  end

  defp partial_delete(credentials, ids) do
    parameters = [
      ids: Helpers.treat_nullable_id_or_struct_list(ids)
    ]

    {response_status, response} = Requests.delete(credentials, 'charge', parameters)

    if response_status != :ok do
      {response_status, response}
    else
      {response_status,
       for(charge <- response["charges"], do: ChargeHelpers.Charge.decode(charge))}
    end
  end

  @doc """
  gets the specified charge PDF file content

  parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - id [string or StarkBank.Charge.Structs.ChargeData]: charge ID or data struct, e.g.: "5718322100305920";
  """
  def get_pdf(credentials, id) do
    Requests.get(
      credentials,
      'charge/' ++ to_charlist(Helpers.extract_id(id)) ++ '/pdf',
      nil,
      false
    )
  end
end
