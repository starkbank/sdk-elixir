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
    def register(credentials, customers) do
      registrations =
        for partial_customers <- Helpers.chunk_list_by_max_limit(customers),
            do: partial_register(credentials, partial_customers)

      Helpers.flatten_responses(registrations)
    end

    defp partial_register(credentials, customers) do
      encoded_customers = for customer <- customers, do: ChargeHelpers.Customer.encode(customer)
      body = %{customers: encoded_customers}

      {status, response} = Requests.post(credentials, 'charge/customer', body)

      if status != :ok do
        {status, response}
      else
        {status,
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
      recursive_get(credentials, fields, tags, tax_id, limit, nil)
    end

    defp recursive_get(credentials, fields, tags, tax_id, limit, cursor) do
      {status, response} = partial_get(credentials, fields, tags, tax_id, limit, cursor)

      if status != :ok do
        {status, response}
      else
        %{cursor: new_cursor, customers: customers} = response

        if is_nil(cursor) or Helpers.limit_below_maximum?(limit) do
          {status, response[:customers]}
        else
          {new_status, new_response} =
            recursive_get(
              credentials,
              fields,
              tags,
              tax_id,
              Helpers.get_recursive_limit(limit),
              new_cursor
            )

          if new_status != :ok do
            {new_status, new_response}
          else
            {new_status, customers ++ new_response[:customers]}
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
        fields: Helpers.treat_list(fields),
        tags: Helpers.treat_list(tags),
        taxId: tax_id,
        limit: Helpers.truncate_limit(limit),
        cursor: cursor
      ]

      {status, response} = Requests.get(credentials, 'charge/customer', parameters)

      if status != :ok do
        {status, response}
      else
        {
          status,
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

      {status, response} = Requests.get(credentials, 'charge/customer/' ++ to_charlist(id))

      if status != :ok do
        {status, response}
      else
        {status, ChargeHelpers.Customer.decode(response["customer"])}
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
        ids: Helpers.treat_list(for customer <- customers, do: Helpers.extract_id(customer))
      ]

      {status, response} = Requests.delete(credentials, 'charge/customer', parameters)

      if status != :ok do
        {status, response}
      else
        {status,
         for(customer <- response["customers"], do: ChargeHelpers.Customer.decode(customer))}
      end
    end

    @doc """
    overwrites the charge customer with the specified ID

    parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customer [StarkBank.Charge.Structs.CustomerData]: charge customer data;
    """
    def overwrite(credentials, customer) do
      encoded_customers = ChargeHelpers.Customer.encode(customer)
      body = %{customer: encoded_customers}

      {status, response} =
        Requests.put(credentials, 'charge/customer/' ++ to_charlist(customer.id), body)

      if status != :ok do
        {status, response}
      else
        {status, ChargeHelpers.Customer.decode(response["customer"])}
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
      recursive_get(credentials, charge_ids, events, limit, nil)
    end

    defp recursive_get(credentials, charge_ids, events, limit, cursor) do
      {status, response} = partial_get(credentials, charge_ids, events, limit, cursor)

      if status != :ok do
        {status, response}
      else
        %{cursor: new_cursor, logs: logs} = response

        if is_nil(cursor) or Helpers.limit_below_maximum?(limit) do
          {status, response[:logs]}
        else
          {new_status, new_response} =
            recursive_get(
              credentials,
              charge_ids,
              events,
              Helpers.get_recursive_limit(limit),
              new_cursor
            )

          if new_status != :ok do
            {new_status, new_response}
          else
            {new_status, logs ++ new_response[:logs]}
          end
        end
      end
    end

    defp partial_get(credentials, charge_ids, events, limit, cursor) do
      parameters = [
        chargeIds: for(charge_id <- charge_ids, do: Helpers.extract_id(charge_id)),
        events: Helpers.treat_list(events),
        limit: limit,
        cursor: cursor
      ]

      {status, response} = Requests.get(credentials, 'charge/log', parameters)

      if status != :ok do
        {status, response}
      else
        {
          status,
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

      {status, response} = Requests.get(credentials, 'charge/log/' ++ to_charlist(id))

      if status != :ok do
        {status, response}
      else
        {status, ChargeHelpers.ChargeLog.decode(response["log"])}
      end
    end
  end

  @doc """
  creates a new charge

  parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - charges [list of StarkBank.Charge.Structs.ChargeData]: charge structs;
  """
  def create(credentials, charges) do
    creations =
      for partial_charges <- Helpers.chunk_list_by_max_limit(charges),
          do: partial_create(credentials, partial_charges)

    Helpers.flatten_responses(creations)
  end

  defp partial_create(credentials, charges) do
    encoded_charges = for charge <- charges, do: ChargeHelpers.Charge.encode(charge)
    body = %{charges: encoded_charges}

    {status, response} = Requests.post(credentials, 'charge', body)

    if status != :ok do
      {status, response}
    else
      {status, for(charge <- response["charges"], do: ChargeHelpers.Charge.decode(charge))}
    end
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
    recursive_get(credentials, status, tags, ids, fields, filter_after, filter_before, limit, nil)
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
    {status, response} =
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

    if status != :ok do
      {status, response}
    else
      %{cursor: new_cursor, charges: charges} = response

      if is_nil(cursor) or Helpers.limit_below_maximum?(limit) do
        {status, response[:charges]}
      else
        {new_status, new_response} =
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

        if new_status != :ok do
          {new_status, new_response}
        else
          {new_status, charges ++ new_response[:charges]}
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
      tags: Helpers.treat_list(tags),
      ids: Helpers.treat_nullable_id_or_struct_list(ids),
      fields: Helpers.treat_list(fields),
      after: Helpers.date_to_string(filter_after),
      before: Helpers.date_to_string(filter_before),
      limit: limit,
      cursor: cursor
    ]

    {status, response} = Requests.get(credentials, 'charge', parameters)

    if status != :ok do
      {status, response}
    else
      {
        status,
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
      ids: Helpers.treat_list(for id <- ids, do: Helpers.extract_id(id))
    ]

    {status, response} = Requests.delete(credentials, 'charge', parameters)

    if status != :ok do
      {status, response}
    else
      {status, for(charge <- response["charges"], do: ChargeHelpers.Charge.decode(charge))}
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
