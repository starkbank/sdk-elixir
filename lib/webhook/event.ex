defmodule StarkBank.Webhook.Event do

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
  alias StarkBank.Payment.Boleto.Log, as: BoletoPaymentLog
  alias StarkBank.Payment.Utility.Log, as: UtilityPaymentLog
  alias EllipticCurve.Signature, as: Signature
  alias EllipticCurve.PublicKey, as: PublicKey
  alias EllipticCurve.Ecdsa, as: Ecdsa

  @moduledoc """
  Groups Webhook-Event related functions

  # Webhook Event struct:

  An Event is the notification received from the subscription to the Webhook.
  Events cannot be created, but may be retrieved from the Stark Bank API to
  list all generated updates on entities.

  ## Attributes:
    - id [string]: unique id returned when the log is created. ex: "5656565656565656"
    - log [Log]: a Log struct from one the subscription services (TransferLog, BoletoLog, BoletoPaymentlog or UtilityPaymentLog)
    - created [DateTime]: creation datetime for the notification event. ex: ~U[2020-03-26 19:32:35.418698Z]
    - delivered [DateTime]: delivery datetime when the notification was delivered to the user url. Will be nil if no successful attempts to deliver the event occurred. ex: ~U[2020-03-26 19:32:35.418698Z]
    - subscription [string]: service that triggered this event. ex: "transfer", "utility-payment"
  """
  defstruct [:id, :log, :created, :delivered, :subscription]

  @doc """
  # Retrieve a specific notification Event

  Receive a single notification Event struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - Event struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, Webhook.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: Webhook.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  # Retrieve notification Events

  Receive a stream of notification Event structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - is_delivered [bool, default nil]: bool to filter successfully delivered events. ex: True or False
    - after_ [Date, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - before [Date, default nil]: date filter for structs only before specified date. ex: ~D[2020-03-25]

  ## Return:
    - stream of Event structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [Webhook.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, is_delivered: is_delivered, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, is_delivered: nil, after_: nil, before: nil})
    Rest.get_list(user, resource(), limit, %{is_delivered: is_delivered, after: after_, before: before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [Webhook.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, is_delivered: is_delivered, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, is_delivered: nil, after_: nil, before: nil})
    Rest.get_list!(user, resource(), limit, %{is_delivered: is_delivered, after: after_, before: before})
  end

  @doc """
  # Delete notification Events

  Delete a list of notification Event entities previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: Event unique id. ex: "5656565656565656"

  ## Return:
    - deleted Event struct with updated attributes
  """
  @spec delete(Project, binary) :: {:ok, Boleto.t()} | {:error, [%Error{}]}
  def delete(user, id) do
    Rest.delete_id(user, resource(), id)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project, binary) :: Boleto.t()
  def delete!(user, id) do
    Rest.delete_id!(user, resource(), id)
  end

  @doc """
  # Set notification Event entity as delivered

  Set notification Event as delivered at the current timestamp (if it was not yet delivered) by passing id.
  After this is set, the event will no longer be returned on queries with is_delivered=False.

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [list of strings]: Event unique ids. ex: "5656565656565656"

  ## Return:
    - target Event with updated attributes
  """
  @spec set_delivered(Project, binary) :: {:ok, Boleto.t()} | {:error, [%Error{}]}
  def set_delivered(user, id) do
    Rest.patch_id(user, resource(), id)
  end

  @doc """
  Same as set_delivered(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec set_delivered!(Project, binary) :: Boleto.t()
  def set_delivered!(user, id) do
    Rest.patch_id!(user, resource(), id)
  end

  @doc """
  # Create single notification Event from a content string

  Create a single Event struct received from event listening at subscribed user endpoint.
  If the provided digital signature does not check out with the StarkBank public key, an "invalidSignature"
  error will be returned.

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - content [string]: response content from request received at user endpoint (not parsed)
    - signature [string]: base-64 digital signature received at response header "Digital-Signature"
    - cache_pid [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.

  ## Return:
    - Event struct with updated attributes
    - Cache PID that holds the Stark Bank public key in order to avoid unnecessary requests to the API on future parses
  """
  @spec parse(Project.t(), binary, binary, PID.t() | nil) ::
          {:ok, {Event.t(), binary}} | {:error, [Error.t()]}
  def parse(user, content, signature, cache_pid \\ nil) do
    parse(user, content, signature, cache_pid, 0)
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(Project.t(), binary, binary, PID.t() | nil) ::
          {Event.t(), any}
  def parse!(user, content, signature, cache_pid \\ nil) do
    case parse(user, content, signature, cache_pid, 0) do
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
      {:ok, true} -> {:ok, {content |> parse_content, cache_pid}}
      {:ok, false} -> parse(user, content, signature, cache_pid |> update_public_key(nil), counter + 1)
      {:error, errors} -> {:error, errors}
    end
  end

  defp parse_content(content) do
    API.from_api_json(
      JSON.decode!(content)["event"],
      &resource_maker/1
    )
  end

  defp verify_signature(_user, _content, _signature_base_64, _cache_pid, counter) when counter > 1 do
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

  defp verify_signature(user, content, signature_base_64, cache_pid, _counter) do
    case get_starkbank_public_key(user, cache_pid) do
      {:ok, public_key} -> {
        :ok,
        (fn p -> Ecdsa.verify?(
          content,
          signature_base_64 |> Signature.fromBase64!(),
          p |> PublicKey.fromPem!()
          ) end
        ).(public_key)
        }
      {:error, errors} -> {:error, errors}
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
    public_key = JSON.decode!(response)["publicKeys"]
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
      created: json[:created] |> Checks.check_datetime,
      delivered: json[:delivered],
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
