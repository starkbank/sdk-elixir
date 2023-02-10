defmodule StarkBank.Event do
  alias __MODULE__, as: Event
  alias EllipticCurve.Signature
  alias EllipticCurve.PublicKey
  alias EllipticCurve.Ecdsa
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.JSON
  alias StarkBank.Utils.API
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error
  alias StarkBank.Utils.Request
  alias StarkBank.Boleto.Log, as: BoletoLog
  alias StarkBank.Invoice.Log, as: InvoiceLog
  alias StarkBank.Transfer.Log, as: TransferLog
  alias StarkBank.BrcodePayment.Log, as: BrcodePaymentLog
  alias StarkBank.BoletoPayment.Log, as: BoletoPaymentLog
  alias StarkBank.UtilityPayment.Log, as: UtilityPaymentLog
  alias StarkBank.TaxPayment.Log, as: TaxPaymentLog
  alias StarkBank.DarfPayment.Log, as: DarfPaymentLog
  alias StarkBank.Deposit.Log, as: DepositLog

  @moduledoc """
  Groups Webhook-Event related functions
  """

  @doc """
  An Event is the notification received from the subscription to the Webhook.
  Events cannot be created, but may be retrieved from the Stark Bank API to
  list all generated updates on entities.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the event is created. ex: "5656565656565656"
    - `:log` [Log]: a Log struct from one the subscription services (Transfer.Log, Boleto.Log, BoletoPayment.log, UtilityPayment.Log or TaxPayment.Log)
    - `:created` [DateTime]: creation datetime for the notification event. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:is_delivered` [bool]: true if the event has been successfully delivered to the user url. ex: false
    - `:subscription` [string]: service that triggered this event. ex: "transfer", "utility-payment"
    - `:workspace_id` [string]: ID of the Workspace that generated this event. Mostly used when multiple Workspaces have Webhooks registered to the same endpoint. ex: "4545454545454545"
  """
  defstruct [
    :id,
    :log,
    :created,
    :is_delivered,
    :subscription,
    :workspace_id
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single notification Event struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Event struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Event.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Event.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of notification Event structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:is_delivered` [bool, default nil]: filter successfully delivered events. ex: true or false
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of Event structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          is_delivered: boolean,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [Event.t()]}}
           | {:error, [Error.t()]}
           | {:halt, any}
           | {:suspend, any},
           any ->
             any)
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          is_delivered: boolean,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [Event.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 Event objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:is_delivered` [bool, default nil]: filter successfully delivered events. ex: true or false
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of Event structs with updated attributes and cursor to retrieve the next page of Event objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          is_delivered: boolean,
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [Event.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          is_delivered: boolean,
          user: Project.t() | Organization.t()
          ) ::
            [Event.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Delete a list of notification Event entities previously created in the Stark Bank API

  ## Parameters (required):
    - `id` [string]: Event unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - deleted Event struct
  """
  @spec delete(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Event.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t() | Organization.t() | nil) :: Event.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc """
  Update notification Event by passing id.
    If is_delivered is true, the event will no longer be returned on queries with is_delivered=false.

  ## Parameters (required):
    - `id` [list of strings]: Event unique ids. ex: "5656565656565656"
    - `:is_delivered` [bool]: If true and event hasn't been delivered already, event will be set as delivered. ex: true

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target Event with updated attributes
  """
  @spec update(binary, is_delivered: bool, user: Project.t() | Organization.t() | nil) ::
          {:ok, Event.t()} | {:error, [%Error{}]}
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters |> Check.enforced_keys([:is_delivered]) |> Enum.into(%{}))
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(binary, is_delivered: bool, user: Project.t() | Organization.t() | nil) :: Event.t()
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters |> Check.enforced_keys([:is_delivered]) |> Enum.into(%{}))
  end

  @doc """
  Create a single Event struct received from event listening at subscribed user endpoint.
  If the provided digital signature does not check out with the StarkBank public key, an "invalidSignature"
  error will be returned.

  ## Parameters (required):
    - `content` [string]: response content from request received at user endpoint (not parsed)
    - `signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Parameters (optional):
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Event struct with updated attributes
    - Cache PID that holds the Stark Bank public key in order to avoid unnecessary requests to the API on future parses
  """
  @spec parse(
          content: binary,
          signature: binary,
          cache_pid: PID,
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {Event.t(), binary}} | {:error, [Error.t()]}
  def parse(parameters) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        parameters |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )

    parse(user, content, signature, cache_pid, 0)
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(
          content: binary,
          signature: binary,
          cache_pid: PID,
          user: Project.t() | Organization.t()
        ) ::
          {Event.t(), any}
  def parse!(parameters) do
    case parse(parameters) do
      {:ok, {event, cache_pid_}} -> {event, cache_pid_}
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  defp parse(user, content, signature, cache_pid, counter) when is_nil(cache_pid) do
    {:ok, new_cache_pid} = Agent.start_link(fn -> %{} end)
    parse(user, content, signature, new_cache_pid, counter)
  end

  defp parse(user, content, signature, cache_pid, counter) do
    case verify_signature(user, content, signature, cache_pid, counter) do
      {:ok, true} ->
        {:ok, {content |> parse_content, cache_pid}}

      {:ok, false} ->
        parse(user, content, signature, cache_pid |> update_public_key(nil), counter + 1)

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp parse_content(content) do
    API.from_api_json(
      JSON.decode!(content)["event"],
      &resource_maker/1
    )
  end

  defp verify_signature(_user, _content, _signature_base_64, _cache_pid, counter)
       when counter > 1 do
    {
      :error,
      [
        %Error{
          code: "invalidSignature",
          message: "The provided signature and content do not match the Stark Bank public key"
        }
      ]
    }
  end

  defp verify_signature(user, content, signature_base_64, cache_pid, counter)
       when is_binary(signature_base_64) and counter <= 1 do
    try do
      signature_base_64 |> Signature.fromBase64!()
    rescue
      _error -> {
        :error,
        [
          %Error{
            code: "invalidSignature",
            message: "The provided signature is not valid"
          }
        ]
      }
    else
      signature -> verify_signature(
        user,
        content,
        signature,
        cache_pid,
        counter
      )
    end
  end

  defp verify_signature(user, content, signature, cache_pid, _counter) do
    case get_starkbank_public_key(user, cache_pid) do
      {:ok, public_key} ->
        {
          :ok,
          (fn p ->
             Ecdsa.verify?(
               content,
               signature,
               p |> PublicKey.fromPem!()
             )
           end).(public_key)
        }

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp get_starkbank_public_key(user, cache_pid) do
    get_public_key(cache_pid) |> fill_public_key(user, cache_pid)
  end

  defp fill_public_key(public_key, user, cache_pid) when is_nil(public_key) do
    case Request.fetch(:get, "public-key", query: %{limit: 1}, user: user) do
      {:ok, response} -> {:ok, response |> extract_public_key(cache_pid)}
      {:error, errors} -> {:error, errors}
    end
  end

  defp fill_public_key(public_key, _user, _cache_pid) do
    {:ok, public_key}
  end

  defp extract_public_key(response, cache_pid) do
    public_key =
      JSON.decode!(response)["publicKeys"]
      |> hd
      |> (fn x -> x["content"] end).()

    update_public_key(cache_pid, public_key)

    public_key
  end

  defp get_public_key(cache_pid) do
    Agent.get(cache_pid, fn map -> Map.get(map, :starkbank_public_key) end)
  end

  defp update_public_key(cache_pid, public_key) do
    Agent.update(cache_pid, fn map -> Map.put(map, :starkbank_public_key, public_key) end)
    cache_pid
  end

  defp resource() do
    {
      "Event",
      &resource_maker/1
    }
  end

  defp resource_maker(json) do
    %Event{
      id: json[:id],
      log: parse_log_json(json[:log], json[:subscription]),
      created: json[:created] |> Check.datetime(),
      is_delivered: json[:is_delivered],
      subscription: json[:subscription],
      workspace_id: json[:workspace_id]
    }
  end

  defp parse_log_json(log, subscription) do
    log |> API.from_api_json(log_maker_by_subscription(subscription))
  rescue
    CaseClauseError -> log
  end

  defp log_maker_by_subscription(subscription) do
    case subscription do
      "transfer" -> &TransferLog.resource_maker/1
      "invoice" -> &InvoiceLog.resource_maker/1
      "boleto" -> &BoletoLog.resource_maker/1
      "brcode-payment" -> &BrcodePaymentLog.resource_maker/1
      "boleto-payment" -> &BoletoPaymentLog.resource_maker/1
      "utility-payment" -> &UtilityPaymentLog.resource_maker/1
      "tax-payment" -> &TaxPaymentLog.resource_maker/1
      "darf-payment" -> &DarfPaymentLog.resource_maker/1
      "deposit" -> &DepositLog.resource_maker/1
    end
  end
end
