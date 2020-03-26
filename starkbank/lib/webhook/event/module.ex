defmodule StarkBank.Webhook.Event do

  @moduledoc """
  Groups Webhook-Event related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.JSON, as: JSON
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Webhook.Event.Data, as: Event
  alias StarkBank.Project.Data, as: Project
  alias StarkBank.Error, as: Error
  alias StarkBank.Utils.Request, as: Request
  alias StarkBank.Boleto.Log, as: BoletoLog
  alias StarkBank.Transfer.Log, as: TransferLog
  alias StarkBank.Payment.Boleto.Log, as: BoletoPaymentLog
  alias StarkBank.Payment.Utility.Log, as: UtilityPaymentLog
  alias EllipticCurve.Signature, as: Signature
  alias EllipticCurve.PublicKey, as: PublicKey
  alias EllipticCurve.Ecdsa, as: Ecdsa

  @doc """
  Retrieve a specific notification Event

  Receive a single notification Event struct previously created in the Stark Bank API by passing its id

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    id [string]: struct unique id. ex: "5656565656565656"
  Return:
    Event struct with updated attributes
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
  Retrieve notification Events

  Receive a stream of notification Event structs previously created in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
  Parameters (optional):
    limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    is_delivered [bool, default nil]: bool to filter successfully delivered events. ex: True or False
    after [Date, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    before [Date, default nil]: date filter for structs only before specified date. ex: ~D[2020-03-25]
  Return:
    stream of Event structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [Webhook.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, is_delivered: is_delivered, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, is_delivered: nil, created_after: nil, created_before: nil})
    Rest.get_list(user, resource(), limit, %{is_delivered: is_delivered, after: created_after, before: created_before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [Webhook.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, is_delivered: is_delivered, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, is_delivered: nil, created_after: nil, created_before: nil})
    Rest.get_list!(user, resource(), limit, %{is_delivered: is_delivered, after: created_after, before: created_before})
  end

  @doc """
  Delete notification Events

  Delete a list of notification Event entities previously created in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    id [string]: Event unique id. ex: "5656565656565656"
  Return:
    deleted Event with updated attributes
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
  Set notification Event entity as delivered

  Set notification Event as delivered at the current timestamp (if it was not yet delivered) by passing id.
  After this is set, the event will no longer be returned on queries with is_delivered=False.

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    id [list of strings]: Event unique ids. ex: "5656565656565656"
  Return:
    target Event with updated attributes
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
  Create single notification Event from a content string

  Create a single Event struct received from event listening at subscribed user endpoint.
  If the provided digital signature does not check out with the StarkBank public key, an "invalidSignature"
  error will be returned.

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    content [string]: response content from request received at user endpoint (not parsed)
    signature [string]: base-64 digital signature received at response header "Digital-Signature"
  Return:
    Event struct with updated attributes
  """
  @spec parse(Project.t(), binary, binary, binary | nil) ::
          {:ok, {Event.t(), binary}} | {:error, [Error.t()]}
  def parse(user, content, signature, starkbank_public_key) do
    parse(user, content, signature, starkbank_public_key, 0)
  end

  @doc """
  Same as parse(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec parse!(Project.t(), binary, binary, binary | nil) ::
          {Event.t(), any}
  def parse!(user, content, signature, starkbank_public_key) do
    case parse(user, content, signature, starkbank_public_key, 0) do
      {:ok, {event, public_key}} -> {event, public_key}
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  defp parse(user, content, signature, starkbank_public_key, counter) do
    case verify_signature(user, content, signature, starkbank_public_key, counter) do
      {:ok, {true, public_key}} -> {
        :ok,
        {
          API.from_api_json(JSON.decode!(content)["event"], &resource_maker/1),
          public_key
          }
        }
      {:ok, {false, _public_key}} -> parse(user, content, signature, nil, counter + 1)
      {:error, errors} -> {:error, errors}
    end
  end

  defp verify_signature(_user, _content, _signature_base_64, _starkbank_public_key, counter) when counter > 1 do
    {
      :error,
      [
        %Error{
          code: "invalidSignature",
          message: "The provided signature and content do not match the StarkBank public key"
        }
      ]
    }
  end

  defp verify_signature(user, content, signature_base_64, starkbank_public_key, _counter) do
    case get_starkbank_public_key(user, starkbank_public_key) do
      {:ok, public_key} -> {
        :ok, {
          (fn p -> Ecdsa.verify?(
            content,
            signature_base_64 |> Signature.fromBase64!(),
            p |> PublicKey.fromPem!()
            ) end).(public_key),
          public_key
          }
        }
      {:error, errors} -> {:error, errors}
    end
  end

  defp get_starkbank_public_key(user, starkbank_public_key) when is_nil(starkbank_public_key) do
    case Request.fetch(user, :get, "public-key", query: %{limit: 1}) do
      {:ok, response} -> {:ok, JSON.decode!(response)["publicKeys"]
                                |> hd
                                |> (fn x -> x["content"] end).()
                         }
      {:error, errors} -> {:error, errors}
    end
  end

  defp get_starkbank_public_key(_user, starkbank_public_key) do
    {:ok, starkbank_public_key}
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
