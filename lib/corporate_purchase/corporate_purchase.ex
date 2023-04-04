defmodule StarkBank.CorporatePurchase do
  alias __MODULE__, as: CorporatePurchase
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
    # CorporatePurchase object
  """

  @doc """
  Displays the CorporatePurchase objects created in your Workspace.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when CorporatePurchase is created. ex: "5656565656565656"
    - `:holder_id` [binary]: card holder unique id. ex: "5656565656565656"
    - `:holder_name` [binary]: card holder name. ex: "Tony Stark"
    - `:center_id` [binary]: target cost center ID. ex: "5656565656565656"
    - `:card_id` [binary]: unique id returned when CorporateCard is created. ex: "5656565656565656"
    - `:card_ending` [binary]: last 4 digits of the card number. ex: "1234"
    - `:description` [binary]: purchase description. ex: "my_description"
    - `:amount` [integer]: CorporatePurchase value in cents. Minimum = 0. ex: 1234 (= R$ 12.34)
    - `:tax` [integer]: IOF amount taxed for international purchases. ex: 1234 (= R$ 12.34)
    - `:issuer_amount` [integer]: issuer amount. ex: 1234 (= R$ 12.34)
    - `:issuer_currency_code` [binary]: issuer currency code. ex: "USD"
    - `:issuer_currency_symbol` [binary]: issuer currency symbol. ex: "$"
    - `:merchant_amount` [integer]: merchant amount. ex: 1234 (= R$ 12.34)
    - `:merchant_currency_code` [binary]: merchant currency code. ex: "USD"
    - `:merchant_currency_symbol` [binary]: merchant currency symbol. ex: "$"
    - `:merchant_category_code` [binary]: merchant category code. ex: "fastFoodRestaurants"
    - `:merchant_category_type` [binary]: merchant category type. ex: "health"
    - `:merchant_country_code` [binary]: merchant country code. ex: "USA"
    - `:merchant_name` [binary]: merchant name. ex: "Google Cloud Platform"
    - `:merchant_display_name` [binary]: merchant name. ex: "Google Cloud Platform"
    - `:merchant_display_url` [binary]: public merchant icon (png image). ex: "https://sandbox.api.starkbank.com/v2/corporate-icon/merchant/ifood.png"
    - `:merchante_fee` [binary]: virtual wallet ID. ex: "5656565656565656"
    - `:method_code` [binary]: method code. ex: "chip", "token", "server", "manual", "magstripe" or "contactless"
    - `:tags` [list of binaries]: list of binaries for tagging returned by the sub-issuer during the authorization. ex: ["travel", "food"]
    - `:corporate_transaction_ids` [binary]: ledger transaction ids linked to this Purchase
    - `:status` [binary]: current CorporateCard status. ex: "approved", "canceled", "denied", "confirmed", "voided"
    - `:updated` [DateTime]: latest update datetime for the CorporatePurchase. ex: ~U[2020-03-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the CorporatePurchase. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
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
    :merchante_fee,
    :method_code,
    :tags,
    :corporate_transaction_ids,
    :status,
    :updated,
    :created
  ]

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
    :merchante_fee,
    :method_code,
    :tags,
    :corporate_transaction_ids,
    :status,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single CorporatePurchase object previously created in the Stark Bank API by its id

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporatePurchase object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, CorporatePurchase.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of CorporatePurchase objects previously created in the Stark Bank API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:merchant_category_types` [list of binaries, default nil]: merchant category type. ex: "health"
    - `:holder_ids` [list of binaries, default []]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:card_ids` [list of binaries, default []]: card  IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["approved", "canceled", "denied", "confirmed", "voided"]
    - `:ids` [list of binaries, default []]: purchase IDs
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporatePurchase objects with updated attributes
  """
  @spec query(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    merchant_category_types: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [CorporatePurchase.t()]}} |
    {:error, [Error.t()]}
  def query(options \\ []) do
    Rest.get_list(
      resource(),
      options
    )
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    merchant_category_types: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 CorporatePurchase objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:merchant_category_types` [list of binaries, default nil]: merchant category type. ex: "health"
    - `:holder_ids` [list of binaries, default []]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:card_ids` [list of binaries, default []]: card  IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["approved", "canceled", "denied", "confirmed", "voided"]
    - `:ids` [list of binaries, default []]: purchase IDs
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporatePurchase objects with updated attributes
    - cursor to retrieve the next page of CorporatePurchase objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    merchant_category_types: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [CorporatePurchase.t()]}} |
    {:error, [Error.t()]}
  def page(options \\ []) do
    Rest.get_page(
      resource(),
      options
    )
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    merchant_category_types: [binary],
    holder_ids: [binary],
    card_ids: [binary],
    status: [binary],
    ids: [binary],
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Create a single verified CorporatePurchase authorization request from a content string
  Use this method to parse and verify the authenticity of the authorization request received at the informed endpoint.
  Authorization requests are posted to your registered endpoint whenever CorporatePurchases are received.
  They present CorporatePurchase data that must be analyzed and answered with approval or declination.
  If the provided digital signature does not check out with the StarkBank public key, a stark.exception.InvalidSignatureException will be raised.
  If the authorization request is not answered within 2 seconds or is not answered with an HTTP status code 200 the CorporatePurchase will go through the pre-configured stand-in validation.

  ## Parameters (required):
    - `:content` [binary]: response content from request received at user endpoint (not parsed)
    - `:signature` [binary]: base-64 digital signature received at response header "Digital-Signature"

  ## Parameters (optional):
    - `cache_pid` [PID, default nil]: PID of the process that holds the public key cache, returned on previous parses. If not provided, a new cache process will be generated.
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Parsed CorporatePurchase object
  """
  @spec parse(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  )::
    {:ok, CorporatePurchase.t()} |
    {:error, [error: Error.t()]}
  def parse(options) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
    Enum.into(
      options |> Check.enforced_keys([:content, :signature]),
      %{cache_pid: nil, user: nil}
    )
    Parse.parse_and_verify(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @spec parse!(
    content: binary,
    signature: binary,
    cache_pid: PID,
    user: Project.t() | Organization.t()
  ) :: any
  def parse!(options \\ []) do
    %{content: content, signature: signature, cache_pid: cache_pid, user: user} =
      Enum.into(
        options |> Check.enforced_keys([:content, :signature]),
        %{cache_pid: nil, user: nil}
      )
    Parse.parse_and_verify!(
      content: content,
      signature: signature,
      cache_pid: cache_pid,
      key: nil,
      resource_maker: &resource_maker/1,
      user: user
    )
  end

  @doc """
  Helps you respond to a PixReversal authorization

  ## Parameters (required):
    - `:status` [binary]: sub-issuer response to the authorization. ex: "approved" or "denied"

  ## Parameters (conditionally-required):
    - `:reason` [binary, default nil]: denial reason. Options: "other", "blocked", "lostCard", "stolenCard", "invalidPin", "invalidCard", "cardExpired", "issuerError", "concurrency", "standInDenial", "subIssuerError", "invalidPurpose", "invalidZipCode", "invalidWalletId", "inconsistentCard", "settlementFailed", "cardRuleMismatch", "invalidExpiration", "prepaidInstallment", "holderRuleMismatch", "insufficientBalance", "tooManyTransactions", "invalidSecurityCode", "invalidPaymentMethod", "confirmationDeadline", "withdrawalAmountLimit", "insufficientCardLimit", "insufficientHolderLimit"

  ## Parameters (optional):
    - `:amount` [binary, default nil]: amount in cents that was authorized. ex: 1234 (= R$ 12.34)
    - `:tags` [list of binaries, default nil]: tags to filter retrieved object. ex: ["tony", "stark"]

    ## Return:
    - Dumped JSON binary that must be returned to us
  """

  @spec response(
    map(),
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, PixReversal.t()} |
    {:error, [Error.t()]}
  def response(status, reason, amount, tags) do
    body = %{status: status, reason: reason, amount: amount, tags: tags}
    params = %{authorization: body}
    params
    |> Jason.encode!
  end

  @spec resource ::
          {<<_::120>>, (nil | maybe_improper_list | map -> StarkBank.CorporatePurchase.t())}
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
      merchante_fee: json[:merchante_fee],
      method_code: json[:method_code],
      tags: json[:tags],
      corporate_transaction_ids: json[:corporate_transaction_ids],
      status: json[:status],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime(),
    }
  end
end
