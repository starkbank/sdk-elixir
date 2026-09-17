defmodule StarkBank.CorporateHolder do
  alias __MODULE__, as: CorporateHolder
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error
  alias StarkBank.CorporateRule
  alias StarkBank.CorporateHolder.Permission

  @moduledoc """
  Groups CorporateHolder related functions
  """

  @doc """
  The CorporateHolder struct describes a card holder that may group several cards.
  When you initialize a CorporateHolder, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the created structs.

  ## Parameters (required):
    - `:name` [string]: card holder name. ex: "Tony Stark"

  ## Parameters (optional):
    - `:center_id` [string, default nil]: target cost center ID. ex: "5656565656565656"
    - `:permissions` [list of CorporateHolder.Permission structs, default nil]: list of Permission structs representing access granted to an user for a particular cardholder.
    - `:rules` [list of CorporateRule structs, default []]: [EXPANDABLE] list of holder spending rules.
    - `:tags` [list of strings, default []]: list of strings for tagging. ex: ["travel", "food"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when CorporateHolder is created. ex: "5656565656565656"
    - `:status` [string, default nil]: current CorporateHolder status. ex: "active", "blocked", "canceled"
    - `:updated` [DateTime, default nil]: latest update datetime for the CorporateHolder. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:created` [DateTime, default nil]: creation datetime for the CorporateHolder. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:name]
  defstruct [
    :name,
    :center_id,
    :permissions,
    :rules,
    :tags,
    :id,
    :status,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of CorporateHolder structs for creation in the Stark Bank API

  ## Parameters (required):
    - `holders` [list of CorporateHolder structs]: list of CorporateHolder structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateHolder structs with updated attributes
  """
  @spec create([CorporateHolder.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [CorporateHolder.t()]} | {:error, [Error.t()]}
  def create(holders, options \\ []) do
    Rest.post(
      resource(),
      holders,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([CorporateHolder.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(holders, options \\ []) do
    Rest.post!(
      resource(),
      holders,
      options
    )
  end

  @doc """
  Receive a single CorporateHolder struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:expand` [list of strings, default nil]: fields to expand information. Options: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateHolder struct with updated attributes
  """
  @spec get(binary, expand: [binary], user: Project.t() | Organization.t() | nil) ::
          {:ok, CorporateHolder.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, expand: [binary], user: Project.t() | Organization.t() | nil) :: CorporateHolder.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of CorporateHolder structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["active", "blocked", "canceled"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:expand` [list of strings, default nil]: fields to expand information. Options: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateHolder structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          status: [binary],
          tags: [binary],
          expand: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [CorporateHolder.t()]}}
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
          ids: [binary],
          status: [binary],
          tags: [binary],
          expand: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [CorporateHolder.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CorporateHolder structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["active", "blocked", "canceled"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:expand` [list of strings, default nil]: fields to expand information. Options: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateHolder structs with updated attributes and cursor to retrieve the next page of CorporateHolder objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          status: [binary],
          tags: [binary],
          expand: [binary],
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [CorporateHolder.t()]}} | {:error, [%Error{}]}
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
          ids: [binary],
          status: [binary],
          tags: [binary],
          expand: [binary],
          user: Project.t() | Organization.t()
          ) ::
            [CorporateHolder.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Update a CorporateHolder by passing its id.

  ## Parameters (required):
    - `id` [string]: CorporateHolder id. ex: "5656565656565656"

  ## Options:
    - `:center_id` [string, default nil]: target cost center ID. ex: "5656565656565656"
    - `:permissions` [list of CorporateHolder.Permission structs, default nil]: list of Permission structs representing access granted to an user for a particular cardholder.
    - `:status` [string, default nil]: you may block the CorporateHolder by passing "blocked" in the status
    - `:name` [string, default nil]: card holder name.
    - `:rules` [list of maps, default nil]: list of maps with "amount", "currencyCode", "id", "interval" and "name" keys, describing the CorporateRules to be updated.
    - `:tags` [list of strings, default nil]: list of strings for tagging.
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target CorporateHolder with updated attributes
  """
  @spec update(binary,
          center_id: binary,
          permissions: [Permission.t() | map],
          status: binary,
          name: binary,
          rules: [map],
          tags: [binary],
          user: Project.t() | Organization.t() | nil
        ) :: {:ok, CorporateHolder.t()} | {:error, [%Error{}]}
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(binary,
          center_id: binary,
          permissions: [Permission.t() | map],
          status: binary,
          name: binary,
          rules: [map],
          tags: [binary],
          user: Project.t() | Organization.t() | nil
        ) :: CorporateHolder.t()
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc """
  Cancel a CorporateHolder entity previously created in the Stark Bank API

  ## Parameters (required):
    - `id` [string]: CorporateHolder unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled CorporateHolder struct
  """
  @spec cancel(binary, user: Project.t() | Organization.t() | nil) :: {:ok, CorporateHolder.t()} | {:error, [%Error{}]}
  def cancel(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(binary, user: Project.t() | Organization.t() | nil) :: CorporateHolder.t()
  def cancel!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "CorporateHolder",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CorporateHolder{
      name: json[:name],
      center_id: json[:center_id],
      permissions: json[:permissions] |> Permission.parse_permissions(),
      rules: json[:rules] |> CorporateRule.parse_rules(),
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
