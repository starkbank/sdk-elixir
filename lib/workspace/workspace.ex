defmodule StarkBank.Workspace do
  alias __MODULE__, as: Workspace
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups Workspace related functions
  """

  @doc """
  Workspaces are bank accounts. They have independent balances, statements, operations and permissions.
  The only property that is shared between your workspaces is that they are linked to your organization,
  which carries your basic informations, such as tax ID, name, etc.

  ## Parameters (required):
    - `:username` [string]: Simplified name to define the workspace URL. This name must be unique across all Stark Bank Workspaces. Ex: "starkbankworkspace"
    - `:name` [string]: Full name that identifies the Workspace. This name will appear when people access the Workspace on our platform, for example. Ex: "Stark Bank Workspace"

  ## Parameters (optional):
    - `:allowed_tax_ids` [list of strings, default []]: list of tax IDs that will be allowed to send Deposits to this Workspace. If empty, all are allowed. ex: ["012.345.678-90", "20.018.183/0001-80"]

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the workspace is created. ex: "5656565656565656"
    - `:status` [string]: current Workspace status. Options: "active", "closed", "frozen" or "blocked"
    - `:organization_id` [string]: unique organization id returned when the organization is created. ex: "5656565656565656"
    - `:picture_url` [string]: public workspace image (png) URL. ex: "https://storage.googleapis.com/api-ms-workspace-sbx.appspot.com/pictures/workspace/6284441752174592.png?20230208220551"
    - `:created` [DateTime]: creation datetime for the balance. ex: ~U[2020-03-26 19:32:35.418698Z]

  """
  @enforce_keys [
    :username,
    :name,
  ]
  defstruct [
    :username,
    :name,
    :allowed_tax_ids,
    :id,
    :status,
    :organization_id,
    :picture_url,
    :created,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a single Workspace for creation in the Stark Bank API

  ## Parameters (required):
    - `:username` [string]: Simplified name to define the workspace URL. This name must be unique across all Stark Bank Workspaces. Ex: "starkbankworkspace"
    - `:name` [string]: Full name that identifies the Workspace. This name will appear when people access the Workspace on our platform, for example. Ex: "Stark Bank Workspace"

  ## Options:
    - `:allowed_tax_ids` [list of strings, default []]: list of tax IDs that will be allowed to send Deposits to this Workspace. If empty, all are allowed. ex: ["012.345.678-90", "20.018.183/0001-80"]
    - `:user` [Organization]: Organization struct with nil workspace_id. Only necessary if default organization has not been set in configs.

  ## Return:
    - Workspace struct with updated attributes
  """
  @spec create(user: Organization.t() | nil, username: binary, name: binary, allowed_tax_ids: [binary]) ::
          {:ok, Workspace.t()} | {:error, [Error.t()]}
  def create(parameters \\ []) do
    %{user: user, username: username, name: name, allowed_tax_ids: allowed_tax_ids} =
      Enum.into(
        parameters |> Check.enforced_keys([:username, :name]),
        %{user: nil}
      )

    Rest.post_single(
      resource(),
      %Workspace{username: username, name: name, allowed_tax_ids: allowed_tax_ids},
      %{user: user}
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(user: Organization.t() | nil, username: binary, name: binary, allowed_tax_ids: [binary]) :: any
  def create!(parameters \\ []) do
    %{user: user, username: username, name: name, allowed_tax_ids: allowed_tax_ids} =
      Enum.into(
        parameters |> Check.enforced_keys([:username, :name]),
        %{user: nil, username: nil, name: nil}
      )

    Rest.post_single!(
      resource(),
      %Workspace{username: username, name: name, allowed_tax_ids: allowed_tax_ids},
      %{user: user}
    )
  end

  @doc """
  Receive a single Workspace struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct. Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Workspace struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Workspace.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Workspace.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Workspace structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:username` [string]: query by the simplified name that defines the workspace URL. This name is always unique across all Stark Bank Workspaces. Ex: "starkbankworkspace"
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of Workspace structs with updated attributes
  """
  @spec query(
          limit: integer,
          username: binary,
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [Workspace.t()]}}
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
          username: binary,
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [Workspace.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 Workspace objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:username` [string]: query by the simplified name that defines the workspace URL. This name is always unique across all Stark Bank Workspaces. Ex: "starkbankworkspace"
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of Workspace structs with updated attributes and cursor to retrieve the next page of Workspace objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          username: binary,
          ids: [binary],
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [Workspace.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          limit: integer,
          username: binary,
          ids: [binary],
          user: Project.t() | Organization.t()
          ) ::
            [Workspace.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Update a Workspace by passing its ID.

  ## Parameters (required):
    - `:id` [string]: Invoice id. ex: '5656565656565656'

  ## Parameters (conditionally required):
    - `:picture_type` [string]: picture MIME type. This parameter will be required if the picture parameter is informed ex: "image/png" or "image/jpeg"

  ## Parameters (optional):
    - `:username` [string, default nil]: Simplified name to define the workspace URL. This name must be unique across all Stark Bank Workspaces. Ex: "starkbank-workspace"
    - `:name` [string, default nil]: Full name that identifies the Workspace. This name will appear when people access the Workspace on our platform, for example. Ex: "Stark Bank Workspace"
    - `:allowed_tax_ids` [list of strings, default nil]: list of tax IDs that will be allowed to send Deposits to this Workspace. If empty, all are allowed. ex: ["012.345.678-90", "20.018.183/0001-80"]
    - `:status` [string, default nil]: current Workspace status. Options: "active" or "blocked"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target Workspace with updated attributes
  """
  @spec update(binary, username: binary, name: binary, allowed_tax_ids: [binary], picture: binary, picture_type: binary, user: Project.t() | Organization.t()) :: {:ok, Workspace.t()} | {:error, [%Error{}]}
  def update(id, parameters \\ []) do

    payload = parameters |> Enum.into(%{})

    if Map.get(payload, :picture) != nil do
      payload = Map.put(payload, :picture, "data:" <> Map.get(payload, :picture_type) <> ";base64," <> Base.encode64(Map.get(payload, :picture)))
      payload = Map.delete(payload, :picture_type)
    end

    Rest.patch_id(resource(), id, payload)
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(binary, username: binary, name: binary, allowed_tax_ids: [binary], user: Project.t() | Organization.t()) :: Workspace.t()
  def update!(id, parameters \\ []) do

    payload = parameters |> Enum.into(%{})

    if Map.get(payload, :picture) != nil do
      payload = Map.put(payload, :picture, "data:" <> Map.get(payload, :picture_type) <> ";base64," <> Base.encode64(Map.get(payload, :picture)))
      payload = Map.delete(payload, :picture_type)
    end
    
    Rest.patch_id!(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc false
  def resource() do
    {
      "Workspace",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Workspace{
      username: json[:username],
      name: json[:name],
      allowed_tax_ids: json[:allowed_tax_ids],
      id: json[:id],
      status: json[:status],
      organization_id: json[:organization_id],
      picture_url: json[:picture_url],
      created: json[:created] |> Check.datetime()
    }
  end
end
