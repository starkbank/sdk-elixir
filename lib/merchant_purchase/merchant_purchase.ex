defmodule StarkBank.MerchantPurchase do
  alias __MODULE__, as: MerchantPurchase
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups MerchantPurchase related functions
  """

  @doc """
  When you initialize a MerchantPurchase, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the struct
  to the Stark Bank API and returns the created struct.

  ## Parameters (required):
    - `:amount` [integer]: MerchantPurchase value in cents. ex: 1234 (= R$ 12.34)
    - `:card_id` [string]: unique id of the MerchantCard or MerchantSession Purchase used. ex: "5656565656565656"
    - `:funding_type` [string]: type of funding used. ex: "credit", "debit"
    - `:installment_count` [integer]: number of installments the purchase is split into. ex: 1

  ## Parameters (optional):
    - `:card_expiration` [string, default nil]: card and holder data, required only when not created through a MerchantSession.
    - `:card_number` [string, default nil]: card and holder data, required only when not created through a MerchantSession.
    - `:card_security_code` [string, default nil]: card and holder data, required only when not created through a MerchantSession.
    - `:holder_name` [string, default nil]: card and holder data, required only when not created through a MerchantSession.
    - `:holder_email` [string, default nil]: card and holder data, required only when not created through a MerchantSession.
    - `:holder_phone` [string, default nil]: card and holder data, required only when not created through a MerchantSession.
    - `:holder_id` [string, default nil]: card and holder data, required only when not created through a MerchantSession.
    - `:billing_country_code` [string, default nil]: billing address data.
    - `:billing_city` [string, default nil]: billing address data.
    - `:billing_state_code` [string, default nil]: billing address data.
    - `:billing_street_line_1` [string, default nil]: billing address data.
    - `:billing_street_line_2` [string, default nil]: billing address data.
    - `:billing_zip_code` [string, default nil]: billing address data.
    - `:metadata` [map, default nil]: additional 3DS metadata sent by the merchant's browser/app.
    - `:soft_descriptor` [string, default nil]: text that will be shown in the holder's bank statement. ex: "my-store"
    - `:tags` [list of strings, default nil]: list of strings for tagging

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when MerchantPurchase is created. ex: "5656565656565656"
    - `:card_ending` [string, default nil]: last 4 digits of the card used. ex: "1234"
    - `:challenge_mode` [string, default nil]: whether 3DS holder verification was used. ex: "enabled", "disabled"
    - `:challenge_url` [string, default nil]: URL to the 3DS challenge, when applicable.
    - `:currency_code` [string, default nil]: currency of the purchase. ex: "BRL"
    - `:end_to_end_id` [string, default nil]: unique transaction id for the acquirer network.
    - `:fee` [integer, default nil]: fee charged when the MerchantPurchase is processed. ex: 200 (= R$ 2.00)
    - `:network` [string, default nil]: card network flag. ex: "visa", "mastercard"
    - `:source` [string, default nil]: locator of the entity that generated the purchase. ex: "merchant-session/{sessionId}"
    - `:status` [string, default nil]: current MerchantPurchase status. ex: "approved", "confirmed", "canceled", "voided"
    - `:created` [DateTime, default nil]: creation datetime for the MerchantPurchase. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the MerchantPurchase. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:amount, :card_id, :funding_type, :installment_count]
  defstruct [
    :amount,
    :card_id,
    :funding_type,
    :installment_count,
    :card_expiration,
    :card_number,
    :card_security_code,
    :holder_name,
    :holder_email,
    :holder_phone,
    :holder_id,
    :billing_country_code,
    :billing_city,
    :billing_state_code,
    :billing_street_line_1,
    :billing_street_line_2,
    :billing_zip_code,
    :metadata,
    :soft_descriptor,
    :tags,
    :id,
    :card_ending,
    :challenge_mode,
    :challenge_url,
    :currency_code,
    :end_to_end_id,
    :fee,
    :network,
    :source,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a MerchantPurchase struct for creation in the Stark Bank API

  ## Parameters (required):
    - `purchase` [MerchantPurchase struct]: MerchantPurchase struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - MerchantPurchase struct with updated attributes
  """
  @spec create(MerchantPurchase.t() | map, user: Project.t() | Organization.t() | nil) ::
          {:ok, MerchantPurchase.t()} | {:error, [Error.t()]}
  def create(purchase, options \\ []) do
    Rest.post_single(resource(), purchase, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(MerchantPurchase.t() | map, user: Project.t() | Organization.t() | nil) :: MerchantPurchase.t()
  def create!(purchase, options \\ []) do
    Rest.post_single!(resource(), purchase, options)
  end

  @doc """
  Receive a single MerchantPurchase struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - MerchantPurchase struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, MerchantPurchase.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: MerchantPurchase.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of MerchantPurchase structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "approved"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:holder_id` [string, default nil]: filter for purchases made with cards belonging to a specific holder. ex: "5656565656565656"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of MerchantPurchase structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          tags: [binary],
          ids: [binary],
          holder_id: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [MerchantPurchase.t()]}}
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
          status: binary,
          tags: [binary],
          ids: [binary],
          holder_id: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [MerchantPurchase.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 MerchantPurchase structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "approved"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:holder_id` [string, default nil]: filter for purchases made with cards belonging to a specific holder. ex: "5656565656565656"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of MerchantPurchase structs with updated attributes and cursor to retrieve the next page of MerchantPurchase objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          tags: [binary],
          ids: [binary],
          holder_id: binary,
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {binary, [MerchantPurchase.t()]}} | {:error, [%Error{}]}
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
          status: binary,
          tags: [binary],
          ids: [binary],
          holder_id: binary,
          user: Project.t() | Organization.t()
        ) ::
          [MerchantPurchase.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Update a MerchantPurchase entity by its id. If the purchase is "approved", you may only
  cancel it by passing status: "canceled" together with amount: 0. If the purchase is
  "confirmed", you may pass status: "reversed" with a lower amount to debit and reverse the
  difference, partially or totally; a partial reversal keeps status "confirmed", while a full
  reversal moves it to "voided".

  ## Parameters (required):
    - `id` [string]: MerchantPurchase id.

  ## Options:
    - `:status` [string, default nil]: "canceled" or "reversed", per the rules above.
    - `:amount` [integer, default nil]: new amount; 0 to cancel an approved purchase, or a lower value to partially/fully reverse a confirmed one.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target MerchantPurchase with updated attributes
  """
  @spec update(binary,
          status: binary,
          amount: integer,
          user: Project.t() | Organization.t() | nil
        ) :: {:ok, MerchantPurchase.t()} | {:error, [%Error{}]}
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(binary,
          status: binary,
          amount: integer,
          user: Project.t() | Organization.t() | nil
        ) :: MerchantPurchase.t()
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc false
  def resource() do
    {
      "MerchantPurchase",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %MerchantPurchase{
      amount: json[:amount],
      card_id: json[:card_id],
      funding_type: json[:funding_type],
      installment_count: json[:installment_count],
      card_expiration: json[:card_expiration],
      card_number: json[:card_number],
      card_security_code: json[:card_security_code],
      holder_name: json[:holder_name],
      holder_email: json[:holder_email],
      holder_phone: json[:holder_phone],
      holder_id: json[:holder_id],
      billing_country_code: json[:billing_country_code],
      billing_city: json[:billing_city],
      billing_state_code: json[:billing_state_code],
      billing_street_line_1: json[:billing_street_line_1],
      billing_street_line_2: json[:billing_street_line_2],
      billing_zip_code: json[:billing_zip_code],
      metadata: json[:metadata],
      soft_descriptor: json[:soft_descriptor],
      tags: json[:tags],
      id: json[:id],
      card_ending: json[:card_ending],
      challenge_mode: json[:challenge_mode],
      challenge_url: json[:challenge_url],
      currency_code: json[:currency_code],
      end_to_end_id: json[:end_to_end_id],
      fee: json[:fee],
      network: json[:network],
      source: json[:source],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
