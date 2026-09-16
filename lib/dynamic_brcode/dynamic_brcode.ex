defmodule StarkBank.DynamicBrcode do
  alias __MODULE__, as: DynamicBrcode
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups DynamicBrcode related functions
  """

  @doc """
  When you initialize a DynamicBrcode, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.
  When a DynamicBrcode is paid, a Deposit is created with a tag containing
  "dynamic-brcode/{uuid}" for conciliation.

  ## Parameters (required):
    - `:amount` [integer]: amount in cents to be received. ex: 100 (= R$ 1.00)

  ## Parameters (optional):
    - `:expiration` [integer, default 3600 (1 hour)]: time interval in seconds counted from creation until the brcode expires. After expiration, the brcode cannot be paid anymore.
    - `:display_description` [string, default nil]: description shown in the payer's bank interface. ex: "Payment for service #1234"
    - `:rules` [list of maps, default nil]: list of maps for modifying DynamicBrcode behavior. Only the "allowedTaxIds" key is currently supported, and at most one rule is accepted.
    - `:tags` [list of strings, default nil]: list of strings for tagging. All tags will be converted to lowercase.

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the DynamicBrcode is created. ex: "5656565656565656"
    - `:uuid` [string, default nil]: unique uuid returned when the DynamicBrcode is created. ex: "901e71f2447c43c886f58366a5432c4b"
    - `:picture_url` [string, default nil]: public QR Code image URL. ex: "https://sandbox.api.starkbank.com/v2/dynamic-brcode/901e71f2447c43c886f58366a5432c4b.png"
    - `:updated` [DateTime, default nil]: latest update datetime for the DynamicBrcode. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:created` [DateTime, default nil]: creation datetime for the DynamicBrcode. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:amount]
  defstruct [
    :amount,
    :expiration,
    :display_description,
    :rules,
    :tags,
    :id,
    :uuid,
    :picture_url,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of DynamicBrcode structs for creation in the Stark Bank API

  ## Parameters (required):
    - `brcodes` [list of DynamicBrcode structs]: list of DynamicBrcode structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DynamicBrcode structs with updated attributes
  """
  @spec create([DynamicBrcode.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [DynamicBrcode.t()]} | {:error, [Error.t()]}
  def create(brcodes, options \\ []) do
    Rest.post(
      resource(),
      brcodes,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([DynamicBrcode.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(brcodes, options \\ []) do
    Rest.post!(
      resource(),
      brcodes,
      options
    )
  end

  @doc """
  Receive a single DynamicBrcode struct previously created in the Stark Bank API by passing its uuid

  ## Parameters (required):
    - `uuid` [string]: struct's unique uuid. ex: "901e71f2447c43c886f58366a5432c4b"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - DynamicBrcode struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, DynamicBrcode.t()} | {:error, [Error.t()]}
  def get(uuid, options \\ []) do
    Rest.get_id(resource(), uuid, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: DynamicBrcode.t()
  def get!(uuid, options \\ []) do
    Rest.get_id!(resource(), uuid, options)
  end

  @doc """
  Receive a stream of DynamicBrcode structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created or updated only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created or updated only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:uuids` [list of strings, default nil]: list of uuids to filter retrieved structs. ex: ["901e71f2447c43c886f58366a5432c4b", "4e2eab725ddd495f9c98ffd97440702d"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of DynamicBrcode structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          uuids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [DynamicBrcode.t()]}}
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
          tags: [binary],
          uuids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [DynamicBrcode.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 DynamicBrcode objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created or updated only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created or updated only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:uuids` [list of strings, default nil]: list of uuids to filter retrieved structs. ex: ["901e71f2447c43c886f58366a5432c4b", "4e2eab725ddd495f9c98ffd97440702d"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DynamicBrcode structs with updated attributes and cursor to retrieve the next page of DynamicBrcode objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          uuids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {binary, [DynamicBrcode.t()]}} | {:error, [Error.t()]}
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
          tags: [binary],
          uuids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          [DynamicBrcode.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "DynamicBrcode",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %DynamicBrcode{
      amount: json[:amount],
      expiration: json[:expiration],
      display_description: json[:display_description],
      rules: json[:rules],
      tags: json[:tags],
      id: json[:id],
      uuid: json[:uuid],
      picture_url: json[:picture_url],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
