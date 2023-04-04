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
  sent to the Stark Bank API. The 'create' function sends the objects
  to the Stark Bank API and returns the list of created objects.
  DynamicBrcodes are conciliated BR Codes that can be used to receive Pix transactions in a convenient way.
  When a DynamicBrcode is paid, a Deposit is created with the tags parameter containing the character “dynamic-brcode/” followed by the DynamicBrcode’s uuid "dynamic-brcode/{uuid}" for conciliation.
  Additionally, all tags passed on the DynamicBrcode will be transferred to the respective Deposit resource.

  ## Parameters (required):
    - `:amount` [integer]: DynamicBrcode value in cents. Minimum = 0 (any value will be accepted). ex: 1234 (= R$ 12.34)

  ## Parameters (optional):
    - `:expiration` [integer, default 59 days]: time interval in seconds between due date and expiration date. ex 123456789
    - `:tags` [list of strings, default nil]: list of strings for tagging

    ## Attributes (return-only):
    - `:id` [string]: id returned on creation, this is the BR code. ex: "00020126360014br.gov.bcb.pix0114+552840092118152040000530398654040.095802BR5915Jamie Lannister6009Sao Paulo620705038566304FC6C"
    - `:uuid` [string]: unique uuid returned when the DynamicBrcode is created. ex: "4e2eab725ddd495f9c98ffd97440702d"
    - `:picture_url` [string]: public QR Code (png image) URL. "https://sandbox.api.starkbank.com/v2/dynamic-brcode/d3ebb1bd92024df1ab6e5a353ee799a4.png"
    - `:created` [DateTime]: creation datetime for the DynamicBrcode. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime]: latest update datetime for the DynamicBrcode. ex: ~U[2020-11-26 17:31:45.482618Z]
  """
  @enforce_keys [
    :amount
  ]
  defstruct [
    :amount,
    :expiration,
    :tags,
    :id,
    :uuid,
    :picture_url,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of DynamicBrcode structs for creation in the Stark Bank API

  ## Parameters (required):
    - `brcodes` [list of DynamicBrcode structs]: list of DynamicBrcode structs to be created in the API

  ## Parameters (optional):
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
  Receive a single DynamicBrcode struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - DynamicBrcode struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, DynamicBrcode.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: DynamicBrcode.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of DynamicBrcode structs previously created in the Stark Bank API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:uuids` [list of strings, default nil]: list of uuids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of DynamicBrcode structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
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

  ## Parameters (optional):
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:uuids` [list of strings, default nil]: list of uuids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
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
            {:ok, {binary, [DynamicBrcode.t()]}} | {:error, [%Error{}]}
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
      tags: json[:tags],
      id: json[:id],
      uuid: json[:uuid],
      picture_url: json[:picture_url],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
