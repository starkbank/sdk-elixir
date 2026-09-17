defmodule StarkBank.CorporatePurchase do
  alias __MODULE__, as: CorporatePurchase
  alias EllipticCurve.Signature
  alias EllipticCurve.PublicKey
  alias EllipticCurve.Ecdsa
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.JSON
  alias StarkBank.Utils.API
  alias StarkBank.Utils.Request
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups CorporatePurchase related functions
  """

  @doc """
  Displays the CorporatePurchase structs created in your Workspace.

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when CorporatePurchase is created. ex: "5656565656565656"
    - `:holder_id` [string, default nil]: card holder unique id. ex: "5656565656565656"
    - `:holder_name` [string, default nil]: card holder name. ex: "Tony Stark"
    - `:center_id` [string, default nil]: target cost center ID. ex: "5656565656565656"
    - `:card_id` [string, default nil]: unique id returned when CorporateCard is created. ex: "5656565656565656"
    - `:card_ending` [string, default nil]: last 4 digits of the card number. ex: "1234"
    - `:description` [string, default nil]: purchase description. ex: "my_description"
    - `:amount` [integer, default nil]: CorporatePurchase value in cents. Minimum = 0. ex: 1234 (= R$ 12.34)
    - `:tax` [integer, default nil]: IOF amount taxed for international purchases. ex: 1234 (= R$ 12.34)
    - `:issuer_amount` [integer, default nil]: issuer amount. ex: 1234 (= R$ 12.34)
    - `:issuer_currency_code` [string, default nil]: issuer currency code. ex: "USD"
    - `:issuer_currency_symbol` [string, default nil]: issuer currency symbol. ex: "$"
    - `:merchant_amount` [integer, default nil]: merchant amount. ex: 1234 (= R$ 12.34)
    - `:merchant_currency_code` [string, default nil]: merchant currency code. ex: "USD"
    - `:merchant_currency_symbol` [string, default nil]: merchant currency symbol. ex: "$"
    - `:merchant_category_code` [string, default nil]: merchant category code. ex: "fastFoodRestaurants"
    - `:merchant_category_type` [string, default nil]: merchant category type. ex: "health"
    - `:merchant_country_code` [string, default nil]: merchant country code. ex: "USA"
    - `:merchant_name` [string, default nil]: merchant name. ex: "Google Cloud Platform"
    - `:merchant_display_name` [string, default nil]: merchant name. ex: "Google Cloud Platform"
    - `:merchant_display_url` [string, default nil]: public merchant icon (png image). ex: "https://sandbox.api.starkbank.com/v2/corporate-icon/merchant/ifood.png"
    - `:merchant_fee` [integer, default nil]: fee charged by the merchant to cover specific costs, such as ATM withdrawal logistics, etc. ex: 200 (= R$ 2.00)
    - `:method_code` [string, default nil]: method code. ex: "chip", "token", "server", "manual", "magstripe" or "contactless"
    - `:tags` [list of strings, default nil]: list of strings for tagging returned by the sub-issuer during the authorization. ex: ["travel", "food"]
    - `:corporate_transaction_ids` [list of strings, default nil]: ledger transaction ids linked to this Purchase
    - `:status` [string, default nil]: current CorporateCard status. ex: "approved", "canceled", "denied", "confirmed", "voided"
    - `:updated` [DateTime, default nil]: latest update datetime for the CorporatePurchase. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:created` [DateTime, default nil]: creation datetime for the CorporatePurchase. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  defstruct [
    :id,
    :holder_id,
    :holder_name,
    :center_id,
    :card_id,
    :card_ending,
    :description,
    :amount,
    :tax,
    :issuer_amount,
    :issuer_currency_code,
    :issuer_currency_symbol,
    :merchant_amount,
    :merchant_currency_code,
    :merchant_currency_symbol,
    :merchant_category_code,
    :merchant_category_type,
    :merchant_country_code,
    :merchant_name,
    :merchant_display_name,
    :merchant_display_url,
    :merchant_fee,
    :method_code,
    :tags,
    :corporate_transaction_ids,
    :status,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single CorporatePurchase struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporatePurchase struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, CorporatePurchase.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: CorporatePurchase.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of CorporatePurchase structs previously created in the Stark Bank API

  ## Options:
    - `:ids` [list of strings, default nil]: purchase IDs
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:merchant_category_types` [list of strings, default nil]: merchant category type. ex: ["health"]
    - `:holder_ids` [list of strings, default nil]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:card_ids` [list of strings, default nil]: card IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["approved", "canceled", "denied", "confirmed", "voided"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporatePurchase structs with updated attributes
  """
  @spec query(
          ids: [binary],
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          merchant_category_types: [binary],
          holder_ids: [binary],
          card_ids: [binary],
          status: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [CorporatePurchase.t()]}}
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
          ids: [binary],
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          merchant_category_types: [binary],
          holder_ids: [binary],
          card_ids: [binary],
          status: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [CorporatePurchase.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CorporatePurchase structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:ids` [list of strings, default nil]: purchase IDs
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:merchant_category_types` [list of strings, default nil]: merchant category type. ex: ["health"]
    - `:holder_ids` [list of strings, default nil]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:card_ids` [list of strings, default nil]: card IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["approved", "canceled", "denied", "confirmed", "voided"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporatePurchase structs with updated attributes and cursor to retrieve the next page of CorporatePurchase objects
  """
  @spec page(
          cursor: binary,
          ids: [binary],
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          merchant_category_types: [binary],
          holder_ids: [binary],
          card_ids: [binary],
          status: [binary],
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [CorporatePurchase.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          ids: [binary],
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          merchant_category_types: [binary],
          holder_ids: [binary],
          card_ids: [binary],
          status: [binary],
          user: Project.t() | Organization.t()
          ) ::
            [CorporatePurchase.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Create a single verified CorporatePurchase authorization request from a content string.
  Use this method to parse and verify the authenticity of the authorization request received at
  your registered endpoint. Authorization requests are posted to that endpoint whenever a
  CorporatePurchase is received. They present CorporatePurchase data that must be analyzed and
  answered with approval or declination. If the provided digital signature does not check out
  with the Stark Bank public key, an "invalidSignature" error will be returned. If the
  authorization request is not answered within 2 seconds or is not answered with an HTTP status
  code 200 the CorporatePurchase will go through the pre-configured stand-in validation.

  ## Parameters (required):
    - `content` [string]: response content from request received at user endpoint (not parsed)
    - `signature` [string]: base-64 digital signature received at response header "Digital-Signature"

  ## Parameters (optional):
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed CorporatePurchase struct
    - Cache PID that holds the Stark Bank public key in order to avoid unnecessary requests to the API on future parses
  """
  @spec parse(
          content: binary,
          signature: binary,
          cache_pid: PID,
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {CorporatePurchase.t(), binary}} | {:error, [Error.t()]}
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
          {CorporatePurchase.t(), any}
  def parse!(parameters) do
    case parse(parameters) do
      {:ok, {purchase, cache_pid_}} -> {purchase, cache_pid_}
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  @doc """
  Helps you respond to a CorporatePurchase authorization request.

  ## Parameters (required):
    - `status` [string]: sub-issuer response to the authorization. ex: "approved" or "denied"

  ## Parameters (conditionally required):
    - `:reason` [string, default nil]: denial reason. Options: "other", "blocked", "lostCard", "stolenCard", "invalidPin", "invalidCard", "cardExpired", "issuerError", "concurrency", "standInDenial", "subIssuerError", "invalidPurpose", "invalidZipCode", "invalidWalletId", "inconsistentCard", "settlementFailed", "cardRuleMismatch", "invalidExpiration", "prepaidInstallment", "holderRuleMismatch", "insufficientBalance", "tooManyTransactions", "invalidSecurityCode", "invalidPaymentMethod", "confirmationDeadline", "withdrawalAmountLimit", "insufficientCardLimit", "insufficientHolderLimit"

  ## Parameters (optional):
    - `:amount` [integer, default nil]: amount in cents that was authorized. ex: 1234 (= R$ 12.34)
    - `:tags` [list of strings, default nil]: tags to filter retrieved object. ex: ["tony", "stark"]

  ## Return:
    - Dumped JSON string that must be returned to us on the CorporatePurchase request
  """
  @spec response(binary, amount: integer, reason: binary, tags: [binary]) :: binary
  def response(status, options \\ []) do
    %{amount: amount, reason: reason, tags: tags} =
      Enum.into(options, %{amount: nil, reason: nil, tags: nil})

    %{
      authorization:
        %{status: status, amount: amount, reason: reason, tags: tags}
        |> API.cast_json_to_api_format()
    }
    |> API.cast_json_to_api_format()
    |> JSON.encode!()
  end

  @doc false
  def resource() do
    {
      "CorporatePurchase",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CorporatePurchase{
      id: json[:id],
      holder_id: json[:holder_id],
      holder_name: json[:holder_name],
      center_id: json[:center_id],
      card_id: json[:card_id],
      card_ending: json[:card_ending],
      description: json[:description],
      amount: json[:amount],
      tax: json[:tax],
      issuer_amount: json[:issuer_amount],
      issuer_currency_code: json[:issuer_currency_code],
      issuer_currency_symbol: json[:issuer_currency_symbol],
      merchant_amount: json[:merchant_amount],
      merchant_currency_code: json[:merchant_currency_code],
      merchant_currency_symbol: json[:merchant_currency_symbol],
      merchant_category_code: json[:merchant_category_code],
      merchant_category_type: json[:merchant_category_type],
      merchant_country_code: json[:merchant_country_code],
      merchant_name: json[:merchant_name],
      merchant_display_name: json[:merchant_display_name],
      merchant_display_url: json[:merchant_display_url],
      merchant_fee: json[:merchant_fee],
      method_code: json[:method_code],
      tags: json[:tags],
      corporate_transaction_ids: json[:corporate_transaction_ids],
      status: json[:status],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
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
      JSON.decode!(content),
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
end
