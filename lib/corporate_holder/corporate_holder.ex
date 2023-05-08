defmodule StarkBank.CorporateHolder do
  alias __MODULE__, as: CorporateHolder
  alias StarkBank.CorporateRule
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.API
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error
  alias StarkBank.CorporateHolder.Permission

  @moduledoc """
    Groups CorporateHolder related functions
  """

  @doc """
  The CorporateHolder describes a card holder that may group several cards.

  ## Parameters (required):
    - `:name` [binary]: card holder's name. ex: "Tony Stark"

    ## Parameters (optional):
    - `:center_id` [binary, default nil]: target cost center ID. ex: "5656565656565656"
    - `:permissions` [list of CorporateHolder.Permission objects, default nil] list of Permission object representing access granted to an user for a particular cardholder.
    - `:rules` [list of CorporateRule objects, default []]: [EXPANDABLE] list of holder spending rules
    - `:tags` [list of binaries, default []]: list of binaries for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when CorporateHolder is created. ex: "5656565656565656"
    - `:status` [binary]: current CorporateHolder status. ex: "active", "blocked" or "canceled"
    - `:updated` [DateTime]: latest update DateTime for the CorporateHolder. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the CorporateHolder. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :name
  ]
  defstruct [
    :id,
    :name,
    :center_id,
    :permissions,
    :rules,
    :tags,
    :status,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of CorporateHolder objects for creation in the Stark Bank API.

  ## Parameters (required):
    - `:holders` [list of CorporateHolder objects]: list of CorporateHolder objects to be created in the API

  ## Parameters (optional):
    - `:expand` [list of strings, default []]: fields to expand information. ex: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateHolder objects with updated attributes
  """
  @spec create(
    holders: [CorporateHolder.t()],
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [CorporateHolder.t()] } |
    { :error, [error: Error.t()] }
  def create(holders, options \\ []) do
    Rest.post(resource(), holders, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    holders: [CorporateHolder.t()],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def create!(holders, options \\ []) do
    Rest.post!(resource(), holders, options)
  end

  @doc """
  Receive a single CorporateHolder object previously created in the Stark Bank API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateHolder object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, [CorporateHolder.t()] } |
    { :error, [error: Error.t()] }
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    id: binary,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of CorporateHolder objects previously created in the Stark Bank API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: ["active", "blocked", "canceled"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateHolder objects with updated attributes
  """
  @spec query(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    status: binary | nil,
    tags: [binary] | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :cont, [CorporateHolder.t()] } |
    { :error, [error: Error.t()] }
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: binary | nil,
    tags: [binary] | nil,
    expand: [binary] | nil,
    ids: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of CorporateHolder objects previously created in the Stark Bank API and the cursor to the next page.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: ["active", "blocked", "canceled"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["rules"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateHolder objects with updated attributes
    - cursor to retrieve the next page of CorporateHolder objects
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    status: binary | nil,
    tags: [binary] | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    { :cont, {binary, [CorporateHolder.t()] }} |
    { :error, [error: Error.t()] }
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    ids: [binary] | nil,
    status: binary | nil,
    tags: [binary] | nil,
    expand: [binary] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Update an CorporateHolder by passing id, if it hasn't been paid yet.

  ## Parameters (required):
    - `:id` [binary]: CorporateHolder id. ex: '5656565656565656'

  ## Parameters (optional):
    - `:center_id` [binary, default nil]: target cost center ID. ex: "5656565656565656"
    - `:permissions` [list of Permission objects, default nil]: list of Permission object representing access granted to an user for a particular cardholder.
    - `:status` [binary, default nil]: You may block the CorporateHolder by passing 'blocked' in the status
    - `:name` [binary, default nil]: card holder name. ex: "Tony Stark"
    - `:tags` [list of binaries, default nil]: list of binaries for tagging. ex: ["tony", "stark"]
    - `:rules` [list of dictionaries, default nil]: list of dictionaries with "amount": int, "currencyCode": binary, "id": binary, "interval": binary, "name": binary pairs
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target CorporateHolder with updated attributes
  """
  @spec update(
    id: binary,
    center_id: binary | nil,
    permissions: [Permission.t()] | nil,
    status: binary | nil,
    name: binary | nil,
    tags: [binary] | nil,
    rules: [CorporateRule.t()] | nil,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, CorporateHolder.t() } |
    { :error, [error: Error.t()] }
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters)
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    center_id: binary | nil,
    permissions: [Permission.t()] | nil,
    status: binary | nil,
    name: binary | nil,
    tags: [binary] | nil,
    rules: [CorporateRule.t()] | nil,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters)
  end

  @doc """
  Cancel an CorporateHolder entity previously created in the Stark Bank API.

  ## Parameters (required):
    - `:id` [binary]: CorporateHolder unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled CorporateHolder object
  """
  @spec cancel(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, CorporateHolder.t() } |
    { :error, [error: Error.t()] }
  def cancel(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
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
      id: json[:id],
      name: json[:name],
      center_id: json[:center_id],
      permissions: json[:permissions] |> Enum.map(fn permission -> API.from_api_json(permission, &Permission.resource_maker/1) end),
      rules: json[:rules] |> Enum.map(fn rule -> API.from_api_json(rule, &CorporateRule.resource_maker/1) end),
      tags: json[:tags],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
