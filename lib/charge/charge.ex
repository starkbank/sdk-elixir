defmodule StarkBank.Charge do
  @moduledoc """
  Used to create and consult charges

  Submodules:
  - StarkBank.Charge.Customer: Used to create and consult charge customers;
  - StarkBank.Charge.Log: Used to consult charge logs;

  Functions:
  - post
  - get
  - delete
  - get_pdf
  """

  alias StarkBank.Utils.Helpers, as: Helpers
  alias StarkBank.Utils.Requests, as: Requests
  alias StarkBank.Charge.Helpers, as: ChargeHelpers

  defmodule Customer do
    @moduledoc """
    Used to create, update and delete charge customers

    Functions:
    - post
    - get
    - get_by_id
    - delete
    - put
    """

    @doc """
    Registers new customers that can be linked with charge emissions

    Parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customers: list of StarkBank.Charge.Structs.CustomerData;

    Returns {:ok, posted_customers}:
    - posted_customers [list of StarkBank.Charge.Structs.CustomerData]: lists all posted customers;

    ## Example:

      iex> StarkBank.Charge.Customer.post(credentials, [customer_1, customer_2])
      {:ok, [customer_1, customer_2]}
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
    Gets charge customers data according to informed parameters

    Parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - options [keyword list]: refines request
      - fields [list of strings]: list of customer fields that should be retrieved from the API;
      - tags [list of strings]: filters customers by the provided tags;
      - tax_id [string]: filters customers by tax ID;
      - limit [int]: maximum results retrieved;

    Returns {:ok, retrieved_customers}:
    - retrieved_customers [list of StarkBank.Charge.Structs.CustomerData]: lists all retrieved customers;

    ## Example:

      iex> StarkBank.Charge.Customer.get(credentials, fields: ["tax_id", "name"], limit: 30)
      {:ok, [customer_1, customer_2, ... customer_30]}
    """
    def get(credentials, options \\ []) do
      %{fields: fields, tags: tags, tax_id: tax_id, limit: limit} =
        Enum.into(options, %{fields: nil, tags: nil, tax_id: nil, limit: nil})

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
    Gets the charge customer with the specified ID

    Parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customer [string or StarkBank.Charge.Structs.CustomerData (with valid ID)]: charge customer ID, e.g.: "6307371336859648";

    Returns {:ok, retrieved_customer}:
    - retrieved_customer [StarkBank.Charge.Structs.CustomerData]: retrieved customer;

    ## Example:

      iex> StarkBank.Charge.Customer.get_by_id(credentials, "6307371336859648")
      {:ok, customer_1}
      iex> StarkBank.Charge.Customer.get_by_id(credentials, customer_1)
      {:ok, customer_1}
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
    Deletes the specified charge customers

    Parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customers [list of strings or list of StarkBank.Charge.Structs.CustomerData (with valid IDs)]: charge customer data or IDs, e.g.: ["6307371336859648"];

    Returns {:ok, deleted_customers}:
    - deleted_customers [list of StarkBank.Charge.Structs.CustomerData]: deleted customers;

    ## Example:

      iex> StarkBank.Charge.Customer.delete(credentials, ["6307371336859648", "5087311326867881"])
      {:ok, [deleted_customer_1, deleted_customer_2]}
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
    Overwrites the charge customer with the specified ID

    Parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - customer [StarkBank.Charge.Structs.CustomerData]: charge customer data;

    Returns {:ok, overwritten_customer}:
    - overwritten_customer [StarkBank.Charge.Structs.CustomerData]: overwritten customer;

    ## Example:

      iex> StarkBank.Charge.Customer.put(credentials, customer_1)
      {:ok, customer_1}
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
    Used to consult charge events;

    Functions:
    - get
    - get_by_id
    """

    @doc """
    Gets the charge logs according to the provided parameters

    Parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - charge_ids [list of strings or list of StarkBank.Charge.Structs.ChargeData]: charge IDs or charge structs, e.g.: ["5618308887871488"];
    - options [keyword list]: refines request
      - events [list of string]: filter by log events, namely: "register", "registered", "overdue", "updated", "canceled", "failed", "paid" or "bank";
      - limit [int]: maximum results retrieved;

    Returns {:ok, charge_logs}:
    - charge_logs [list of StarkBank.Charge.Structs.ChargeLogData]: retrieved charge logs;

    ## Example:

      iex> StarkBank.Charge.Log.get(credentials, ["6307371336859648", charge])
      {:ok, [charge_log_1, charge_log_2, ..., charge_log_n]}
    """
    def get(credentials, charge_ids, options \\ []) do
      %{events: events, limit: limit} = Enum.into(options, %{events: nil, limit: nil})

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
    Gets the charge log specified by the provided ID;

    Parameters:
    - credentials [PID]: agent PID returned by StarkBank.Auth.login;
    - charge_log_id [string or StarkBank.Charge.Structs.ChargeLogData]: charge log ID or struct, e.g.: "6743665380687872";

    Returns {:ok, charge_log}:
    - charge_log [StarkBank.Charge.Structs.ChargeLogData]: retrieved charge log;

    ## Example:

      iex> StarkBank.Charge.Log.get_by_id(credentials, "6307371336859648")
      {:ok, charge_log}
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
  Creates new charges.
  For each charge customer that is specified without an ID,
  the SDK will first get customers by its tax_id and,
  if no customers are a full match or if the 'overwrite_customer_on_mismatch' is false (default),
  a new customer will be created and associated with the charge.
  If 'overwrite_customer_on_mismatch' is true, the first retrieved customer will be overwritten with the provided customer data.
  Therefore, providing ID-less customers may slow the function down significantly, due to the possibly great number of subcalls to the API.

  Parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - charges [list of StarkBank.Charge.Structs.ChargeData]: charge structs;
  - options [keyword list]: refines request
    - overwrite_customer_on_mismatch [bool, default false]: if true, first mismatching customer will be overwritten, if any; if false, new customer will be created (only active if no matching customers are located)
    - discount [int]: defines discount in cents if charge is paid before discountDate (if discount is defined, discountDate must also be defined)
    - discount_date [date or string ("%Y-%m-%d")]: defines up to when the defined discount will be valid (if discount is defined, discountDate must also be defined)

  Returns {:ok, posted_charges}:
  - posted_charges [list of StarkBank.Charge.Structs.ChargeData]: posted charges;

  ## Example:

    iex> StarkBank.Charge.post(credentials, [charge_1, charge_2])
    {:ok, [charge_1, charge_2]}
  """
  def post(credentials, charges, options \\ []) do
    %{overwrite_customer_on_mismatch: overwrite_customer_on_mismatch} =
      Enum.into(options, %{overwrite_customer_on_mismatch: false})

    charges =
      for partial_charges <- Helpers.chunk_list_by_max_limit(charges),
          do: partial_post(credentials, partial_charges, overwrite_customer_on_mismatch)

    Helpers.flatten_responses(charges)
  end

  defp partial_post(credentials, charges, overwrite_customer_on_mismatch) do
    filled_charges =
      fill_charges_with_customer_ids(credentials, charges, overwrite_customer_on_mismatch)

    encoded_charges = for charge <- filled_charges, do: ChargeHelpers.Charge.encode(charge)
    body = %{charges: encoded_charges}

    {response_status, response} = Requests.post(credentials, 'charge', body)

    if response_status != :ok do
      {response_status, response}
    else
      {response_status,
       for(charge <- response["charges"], do: ChargeHelpers.Charge.decode(charge))}
    end
  rescue
    e in MatchError -> {:error, e}
  end

  defp fill_charges_with_customer_ids(credentials, charges, overwrite_customer_on_mismatch) do
    charges_with_customer_ids =
      for charge <- charges, !is_nil(Helpers.extract_id(charge.customer)), do: charge

    charges_without_customer_ids =
      for charge <- charges, is_nil(Helpers.extract_id(charge.customer)), do: charge

    located_customers =
      for charge <- charges_without_customer_ids,
          do: locate_or_make_customer(credentials, charge, overwrite_customer_on_mismatch)

    charges_with_located_customers =
      for charge <- charges_without_customer_ids,
          do: fill_charge_customer_id(charge, located_customers)

    charges_with_customer_ids ++ charges_with_located_customers
  end

  defp locate_or_make_customer(credentials, charge, overwrite_customer_on_mismatch) do
    customer = charge.customer

    {:ok, customer_candidates} =
      Customer.get(
        credentials,
        tags: customer.tags,
        tax_id: customer.tax_id
      )

    matching_customer = find_matching_customer(customer, customer_candidates)

    if !is_nil(matching_customer) do
      matching_customer
    else
      post_or_put_customer(
        credentials,
        customer,
        customer_candidates,
        overwrite_customer_on_mismatch
      )
    end
  end

  defp post_or_put_customer(
         credentials,
         customer,
         customer_candidates,
         overwrite_customer_on_mismatch
       )
       when overwrite_customer_on_mismatch and length(customer_candidates) > 0 do
    {:ok, put_customer} =
      Customer.put(
        credentials,
        %StarkBank.Charge.Structs.CustomerData{
          customer
          | id: hd(customer_candidates).id
        }
      )

    put_customer
  end

  defp post_or_put_customer(
         credentials,
         customer,
         _customer_candidates,
         _overwrite_customer_on_mismatch
       ) do
    {:ok, post_customers} = Customer.post(credentials, [customer])
    hd(post_customers)
  end

  defp fill_charge_customer_id(charge, temp_customers) do
    %StarkBank.Charge.Structs.ChargeData{
      charge
      | customer: find_matching_customer(charge.customer, temp_customers)
    }
  end

  defp find_matching_customer(base_customer, [comp_customer | other_comp_customers]) do
    if customers_match?(base_customer, comp_customer) do
      comp_customer
    else
      find_matching_customer(base_customer, other_comp_customers)
    end
  end

  defp find_matching_customer(_base_customer, []) do
    nil
  end

  defp customers_match?(base_customer, comp_customer) do
    base_address = base_customer.address
    comp_address = comp_customer.address

    customer_tax_id = base_customer.tax_id |> ChargeHelpers.Customer.normalize_tax_id()
    comp_customer_tax_id = comp_customer.tax_id |> ChargeHelpers.Customer.normalize_tax_id()

    Helpers.nullable_fields_match?(base_customer.name, comp_customer.name) and
      Helpers.nullable_fields_match?(base_customer.email, comp_customer.email) and
      Helpers.nullable_fields_match?(customer_tax_id, comp_customer_tax_id) and
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
  Gets charges according to the provided parameters

  Parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - options [keyword list]: refines request
    - status [string]: filters specified charge status, namely: "created", "registered", "paid", "overdue", "canceled" or "failed";
    - tags [list of strings]: filters charges by tags, e.g.: ["client1", "cash-in"];
    - ids [list of strings or StarkBank.Charge.Structs.ChargeData]: charge IDs or data structs to be retrieved, e.g.: ["5718322100305920", "5705293853884416"];
    - fields [list of strings]: selects charge data fields on API response, e.g.: ["id", "amount", "status"];
    - filter_after [date or string ("%Y-%m-%d")]: only gets charges created after this date, e.g.: "2019-04-01";
    - filter_before [date or string ("%Y-%m-%d")]: only gets charges created before this date, e.g.: "2019-05-01";
    - limit [int]: maximum results retrieved;

  Returns {:ok, retrieved_charges}:
  - retrieved_charges [list of StarkBank.Charge.Structs.ChargeData]: retrieved charges;

  ## Example:

    iex> StarkBank.Charge.get(credentials, tags: ["test", "stark"], filter_after: Date.add(Date.utc_today(), -7))
    {:ok, [charge_1, charge_2, ..., charge_n]}
  """
  def get(
        credentials,
        options \\ []
      ) do
    %{
      status: status,
      tags: tags,
      ids: ids,
      fields: fields,
      filter_after: filter_after,
      filter_before: filter_before,
      limit: limit
    } =
      Enum.into(options, %{
        status: nil,
        tags: nil,
        ids: nil,
        fields: nil,
        filter_after: nil,
        filter_before: nil,
        limit: nil
      })

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
  Deletes the specified charges

  Parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - charges [list of strings or StarkBank.Charge.Structs.ChargeData]: charge IDs or data structs to be deleted, e.g.: ["5718322100305920", "5705293853884416"];

  Returns {:ok, deleted_charges}:
  - deleted_charges [list of StarkBank.Charge.Structs.ChargeData]: deleted charges;

  ## Example:

    iex> StarkBank.Charge.delete(credentials, ["1872563178531872", charge_2, "1092381029381092", charge_4])
    {:ok, [charge_1, charge_2, charge_3, charge_4]}
  """
  def delete(credentials, charges) do
    deletions =
      for partial_charges <- Helpers.chunk_list_by_max_limit(charges),
          do: partial_delete(credentials, partial_charges)

    Helpers.flatten_responses(deletions)
  end

  defp partial_delete(credentials, charges) do
    parameters = [
      ids: Helpers.treat_nullable_id_or_struct_list(charges)
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
  Gets the specified charge PDF file content

  Parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;
  - charge [string or StarkBank.Charge.Structs.ChargeData]: charge ID or data struct, e.g.: "5718322100305920";

  Returns {:ok, pdf_content}:
  - pdf_content [string]: pdf file content;

  ## Example:

    iex> StarkBank.Charge.get_pdf(credentials, "1872563178531872")
    {:ok, pdf_content}
    iex> StarkBank.Charge.get_pdf(credentials, charge)
    {:ok, pdf_content}
  """
  def get_pdf(credentials, charge) do
    Requests.get(
      credentials,
      'charge/' ++ to_charlist(Helpers.extract_id(charge)) ++ '/pdf',
      nil,
      false
    )
  end
end
