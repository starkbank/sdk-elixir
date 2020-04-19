defmodule StarkBank.Event do
  alias __MODULE__, as: Event
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.JSON, as: JSON
  alias StarkBank.Utils.API, as: API
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error
  alias StarkBank.Utils.Request, as: Request
  alias StarkBank.Boleto.Log, as: BoletoLog
  alias StarkBank.Transfer.Log, as: TransferLog
  alias StarkBank.BoletoPayment.Log, as: BoletoPaymentLog
  alias StarkBank.UtilityPayment.Log, as: UtilityPaymentLog
  alias EllipticCurve.Signature, as: Signature
  alias EllipticCurve.PublicKey, as: PublicKey
  alias EllipticCurve.Ecdsa, as: Ecdsa

  @moduledoc """
  Groups Webhook-Event related functions
  """

  @doc """
  An Event is the notification received from the subscription to the Webhook.
  Events cannot be created, but may be retrieved from the Stark Bank API to
  list all generated updates on entities.

  ## Attributes:
    - id [string]: unique id returned when the log is created. ex: "5656565656565656"
    - log [Log]: a Log struct from one the subscription services (Transfer.Log, Boleto.Log, BoletoPayment.log or UtilityPayment.Log)
    - created [DateTime]: creation datetime for the notification event. ex: ~U[2020-03-26 19:32:35.418698Z]
    - is_delivered [bool]: true if the event has been successfully delivered to the user url. ex: false
    - subscription [string]: service that triggered this event. ex: "transfer", "utility-payment"
  """
  defstruct [:id, :log, :created, :is_delivered, :subscription]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single notification Event struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - Event struct with updated attributes
  """
  @spec get(Project.t(), binary) :: {:ok, Event.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project.t(), binary) :: Event.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of notification Event structs previously created in the Stark Bank API

  ## Keyword Args:
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - after [Date, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - before [Date, default nil]: date filter for structs only before specified date. ex: ~D[2020-03-25]
    - is_delivered [bool, default nil]: filter successfully delivered events. ex: true or false
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - stream of Event structs with updated attributes
  """
  @spec query(any) ::
          ({:cont, {:ok, [Event.t()]}}
           | {:error, [Error.t()]}
           | {:halt, any}
           | {:suspend, any},
           any ->
             any)
  def query(options \\ []) do
    Rest.get_list(resource(), options |> Checks.check_options(true))
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(any) ::
          ({:cont, [Event.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options |> Checks.check_options(true))
  end

  @doc """
  Delete a list of notification Event entities previously created in the Stark Bank API

  ## Parameters (required):
    - id [string]: Event unique id. ex: "5656565656565656"

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - deleted Event struct with updated attributes
  """
  @spec delete(Project.t(), binary) :: {:ok, Event.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project.t(), binary) :: Event.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc """
  Update notification Event by passing id.
    If is_delivered is true, the event will no longer be returned on queries with is_delivered=false.

  ## Parameters (required):
    - id [list of strings]: Event unique ids. ex: "5656565656565656"

  ## Keyword Args:
    - is_delivered [bool]: If true and event hasn't been delivered already, event will be set as delivered. ex: true
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - target Event with updated attributes
  """
  @spec update(binary, any) :: {:ok, Event.t()} | {:error, [%Error{}]}
  def update(id, options \\ []) do
    Rest.patch_id(resource(), id, options |> Enum.into(%{}))
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(binary, any) :: Event.t()
  def update!(id, options \\ []) do
    Rest.patch_id!(resource(), id, options |> Enum.into(%{}))
  end

  @doc """
  Create a single Event struct received from event listening at subscribed user endpoint.
  If the provided digital signature does not check out with the StarkBank public key, an "invalidSignature"
  error will be returned.

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().
    - content [string]: response content from request received at user endpoint (not parsed)
    - signature [string]: base-64 digital signature received at response header "Digital-Signature"
    - cache_pid [PID, default nil] (optional): PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.

  ## Return:
    - Event struct with updated attributes
    - Cache PID that holds the Stark Bank public key in order to avoid unnecessary requests to the API on future parses
  """
  @spec parse(any) ::
          {:ok, {Event.t(), binary}} | {:error, [Error.t()]}
  def parse(options) do
    options =
      Keyword.merge(options, user: StarkBank.Utils.Request.default_project(), cache_pid: nil)
      |> Enum.into(%{})

    %{
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      user: user
    } = options

    parse(user, content, signature, cache_pid, 0)
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(any) ::
          {Event.t(), any}
  def parse!(options) do
    case parse(options) do
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
    verify_signature(
      user,
      content,
      signature_base_64 |> Signature.fromBase64!(),
      cache_pid,
      counter
    )
  rescue
    _error ->
      {
        :error,
        [
          %Error{
            code: "invalidSignature",
            message: "The provided signature is not valid"
          }
        ]
      }
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
    case Request.fetch(user, :get, "public-key", query: %{limit: 1}) do
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
      log: json[:log] |> API.from_api_json(log_maker_by_subscription(json[:subscription])),
      created: json[:created] |> Checks.check_datetime(),
      is_delivered: json[:is_delivered],
      subscription: json[:subscription]
    }
  end

  defp log_maker_by_subscription(subscription) do
    case subscription do
      "transfer" -> &TransferLog.resource_maker/1
      "boleto" -> &BoletoLog.resource_maker/1
      "boleto-payment" -> &BoletoPaymentLog.resource_maker/1
      "utility-payment" -> &UtilityPaymentLog.resource_maker/1
    end
  end
end
