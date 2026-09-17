defmodule StarkBank.MerchantSession do
  alias __MODULE__, as: MerchantSession
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.API
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error
  alias StarkBank.MerchantSession.AllowedInstallment
  alias StarkBank.MerchantSession.Purchase

  @moduledoc """
  Groups MerchantSession related functions
  """

  @doc """
  When you initialize a MerchantSession, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the struct to the
  Stark Bank API and returns the created struct.

  ## Parameters (required):
    - `:allowed_funding_types` [list of strings]: funding types allowed for the purchase. Options: "credit", "debit"
    - `:allowed_installments` [list of MerchantSession.AllowedInstallment structs]: amount/installment-count combinations allowed for the purchase
    - `:expiration` [integer]: time in seconds from creation until the session expires; after expiration, no purchase can be created with it

  ## Parameters (optional):
    - `:allowed_ips` [list of strings, default []]: IP addresses allowed to create a purchase with this session
    - `:challenge_mode` [string, default "enabled"]: whether 3DS holder verification is used. Options: "enabled", "disabled"
    - `:tags` [list of strings, default []]: list of strings for tagging. All tags will be converted to lowercase.

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when MerchantSession is created. ex: "5656565656565656"
    - `:uuid` [string, default nil]: unique uuid returned when MerchantSession is created, used to create a MerchantSession Purchase. ex: "901e71f2447c43c886f58366a5432c4b"
    - `:holder_id` [string, default nil]: unique id of the card holder associated with this session, when applicable.
    - `:soft_descriptor` [string, default nil]: text that will be shown in the holder's bank statement, when applicable.
    - `:status` [string, default nil]: current MerchantSession status. ex: "created", "expired"
    - `:created` [DateTime, default nil]: creation datetime for the MerchantSession. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the MerchantSession. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:allowed_funding_types, :allowed_installments, :expiration]
  defstruct [
    :allowed_funding_types,
    :allowed_installments,
    :expiration,
    :allowed_ips,
    :challenge_mode,
    :tags,
    :id,
    :uuid,
    :holder_id,
    :soft_descriptor,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a MerchantSession struct for creation in the Stark Bank API

  ## Parameters (required):
    - `session` [MerchantSession struct]: MerchantSession struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - MerchantSession struct with updated attributes
  """
  @spec create(MerchantSession.t() | map, user: Project.t() | Organization.t() | nil) ::
          {:ok, MerchantSession.t()} | {:error, [Error.t()]}
  def create(session, options \\ []) do
    Rest.post_single(resource(), session, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(MerchantSession.t() | map, user: Project.t() | Organization.t() | nil) :: MerchantSession.t()
  def create!(session, options \\ []) do
    Rest.post_single!(resource(), session, options)
  end

  @doc """
  Receive a single MerchantSession struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - MerchantSession struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, MerchantSession.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: MerchantSession.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of MerchantSession structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "created"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:holder_id` [string, default nil]: filter for sessions belonging to a specific card holder. ex: "5656565656565656"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of MerchantSession structs with updated attributes
  """
  @spec query(
          limit: integer,
          status: binary,
          tags: [binary],
          ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          holder_id: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [MerchantSession.t()]}}
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
          status: binary,
          tags: [binary],
          ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          holder_id: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [MerchantSession.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 MerchantSession structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "created"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:holder_id` [string, default nil]: filter for sessions belonging to a specific card holder. ex: "5656565656565656"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of MerchantSession structs with updated attributes and cursor to retrieve the next page of MerchantSession objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          status: binary,
          tags: [binary],
          ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          holder_id: binary,
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [MerchantSession.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          limit: integer,
          status: binary,
          tags: [binary],
          ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          holder_id: binary,
          user: Project.t() | Organization.t()
          ) ::
            [MerchantSession.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Send a MerchantSession.Purchase struct linked to a previously created MerchantSession, identified by its uuid,
  for creation in the Stark Bank API. Depending on the MerchantSession's allowed_funding_types and 3DS
  configuration, the billing and card holder fields on the MerchantSession.Purchase (card_expiration,
  card_number, card_security_code, holder_name, holder_email, holder_phone, holder_id, billing_country_code,
  billing_city, billing_state_code, billing_street_line_1, billing_street_line_2, billing_zip_code) and the
  3DS metadata may be conditionally required.

  ## Parameters (required):
    - `uuid` [string]: MerchantSession unique uuid returned on creation. ex: "901e71f2447c43c886f58366a5432c4b"
    - `purchase` [MerchantSession.Purchase struct]: MerchantSession.Purchase struct to be created against this session

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - MerchantSession.Purchase struct with updated attributes
  """
  @spec purchase(binary, Purchase.t() | map, user: Project.t() | Organization.t() | nil) ::
          {:ok, Purchase.t()} | {:error, [%Error{}]}
  def purchase(uuid, purchase, options \\ []) do
    Rest.post_sub_resource(resource() |> elem(0), Purchase.resource(), uuid, purchase, options |> Enum.into(%{}))
  end

  @doc """
  Same as purchase(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec purchase!(binary, Purchase.t() | map, user: Project.t() | Organization.t() | nil) :: Purchase.t()
  def purchase!(uuid, purchase, options \\ []) do
    Rest.post_sub_resource!(resource() |> elem(0), Purchase.resource(), uuid, purchase, options |> Enum.into(%{}))
  end

  @doc false
  def resource() do
    {
      "MerchantSession",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %MerchantSession{
      allowed_funding_types: json[:allowed_funding_types],
      allowed_installments: json[:allowed_installments] |> parse_allowed_installments(),
      expiration: json[:expiration],
      allowed_ips: json[:allowed_ips],
      challenge_mode: json[:challenge_mode],
      tags: json[:tags],
      id: json[:id],
      uuid: json[:uuid],
      holder_id: json[:holder_id],
      soft_descriptor: json[:soft_descriptor],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end

  defp parse_allowed_installments(nil), do: nil

  defp parse_allowed_installments(allowed_installments) do
    Enum.map(allowed_installments, fn
      %AllowedInstallment{} = allowed_installment -> allowed_installment
      allowed_installment -> allowed_installment |> API.from_api_json(&AllowedInstallment.resource_maker/1)
    end)
  end
end
