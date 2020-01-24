defmodule Charge do
  defmodule Customer do
    def register(credentials, customers) do
      registrations =
        for partial_customers <- Helpers.chunk_list_by_max_limit(customers),
            do: partial_register(credentials, partial_customers)

      try do
        {:ok, List.flatten(for {:ok, response} <- registrations, do: response)}
      rescue
        e in MatchError -> {:error, e}
      end
    end

    defp partial_register(credentials, customers) do
      encoded_customers = for customer <- customers, do: Helpers.Customer.encode(customer)
      body = %{customers: encoded_customers}

      {status, response} = Requests.post(credentials, 'charge/customer', body)

      if status != :ok do
        {status, response}
      else
        {status, for(customer <- response["customers"], do: Helpers.Customer.decode(customer))}
      end
    end

    def get(credentials, fields \\ nil, tags \\ nil, taxId \\ nil, limit \\ nil) do
      recursive_get(credentials, fields, tags, taxId, limit, nil)
    end

    defp recursive_get(credentials, fields, tags, taxId, limit, cursor) do
      {status, response} = partial_get(credentials, fields, tags, taxId, limit, cursor)

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
              taxId,
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
           taxId,
           limit,
           cursor
         ) do
      parameters = [
        fields: Helpers.treat_list(fields),
        tags: Helpers.treat_list(tags),
        taxId: taxId,
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
              for(customer <- response["customers"], do: Helpers.Customer.decode(customer))
          }
        }
      end
    end

    def get_by_id(credentials, customer) do
      id = Helpers.extract_id(customer)

      {status, response} = Requests.get(credentials, 'charge/customer/' ++ to_charlist(id))

      if status != :ok do
        {status, response}
      else
        {status, Helpers.Customer.decode(response["customer"])}
      end
    end

    def delete(credentials, customers) do
      deletions =
        for partial_customers <- Helpers.chunk_list_by_max_limit(customers),
            do: partial_delete(credentials, partial_customers)

      try do
        {:ok, List.flatten(for {:ok, response} <- deletions, do: response)}
      rescue
        e in MatchError -> {:error, e}
      end
    end

    defp partial_delete(credentials, customers) do
      parameters = [
        ids: Helpers.treat_list(for customer <- customers, do: Helpers.extract_id(customer))
      ]

      {status, response} = Requests.delete(credentials, 'charge/customer', parameters)

      if status != :ok do
        {status, response}
      else
        {status, for(customer <- response["customers"], do: Helpers.Customer.decode(customer))}
      end
    end

    def overwrite(credentials, customer) do
      encoded_customers = Helpers.Customer.encode(customer)
      body = %{customer: encoded_customers}

      {status, response} =
        Requests.put(credentials, 'charge/customer/' ++ to_charlist(customer.id), body)

      if status != :ok do
        {status, response}
      else
        {status, Helpers.Customer.decode(response["customer"])}
      end
    end
  end

  defmodule Log do
    @heredocs """
    allowed events: [register, registered, overdue, updated, canceled, failed, paid, bank]
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
            logs: for(log <- response["logs"], do: Helpers.ChargeLog.decode(log))
          }
        }
      end
    end

    def get_by_id(credentials, charge_log_id) do
      id = Helpers.extract_id(charge_log_id)

      {status, response} = Requests.get(credentials, 'charge/log/' ++ to_charlist(id))

      if status != :ok do
        {status, response}
      else
        {status, Helpers.ChargeLog.decode(response["log"])}
      end
    end
  end

  def create(credentials, charges) do
    creations =
      for partial_charges <- Helpers.chunk_list_by_max_limit(charges),
          do: partial_create(credentials, partial_charges)

    try do
      {:ok, List.flatten(for {:ok, response} <- creations, do: response)}
    rescue
      e in MatchError -> {:error, e}
    end
  end

  defp partial_create(credentials, charges) do
    encoded_charges = for charge <- charges, do: Helpers.Charge.encode(charge)
    body = %{charges: encoded_charges}

    {status, response} = Requests.post(credentials, 'charge', body)

    if status != :ok do
      {status, response}
    else
      {status, for(charge <- response["charges"], do: Helpers.Charge.decode(charge))}
    end
  end

  @heredocs """
  accepted status: created, registered, paid, overdue, canceled, failed
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
      ids: Helpers.treat_list(ids),
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
          charges: for(charge <- response["charges"], do: Helpers.Charge.decode(charge))
        }
      }
    end
  end

  def delete(credentials, ids) do
    deletions =
      for partial_ids <- Helpers.chunk_list_by_max_limit(ids),
          do: partial_delete(credentials, partial_ids)

    try do
      {:ok, List.flatten(for {:ok, response} <- deletions, do: response)}
    rescue
      e in MatchError -> {:error, e}
    end
  end

  defp partial_delete(credentials, ids) do
    parameters = [
      ids: Helpers.treat_list(ids)
    ]

    {status, response} = Requests.delete(credentials, 'charge', parameters)

    if status != :ok do
      {status, response}
    else
      {status, for(charge <- response["charges"], do: Helpers.Charge.decode(charge))}
    end
  end

  def get_pdf(credentials, id) do
    Requests.get(
      credentials,
      'charge/' ++ to_charlist(Helpers.extract_id(id)) ++ '/pdf',
      nil,
      false
    )
  end
end
