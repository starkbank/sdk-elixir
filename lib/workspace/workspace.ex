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

  ## Attributes (return-only):
    - `:id` [string, default None]: unique id returned when the workspace is created. ex: "5656565656565656"
  """
  @enforce_keys [
    :username,
    :name,
  ]
  defstruct [
    :username,
    :name,
    :id,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a single Workspace for creation in the Stark Bank API

  ## Parameters (required):
    - `:username` [string]: Simplified name to define the workspace URL. This name must be unique across all Stark Bank Workspaces. Ex: "starkbankworkspace"
    - `:name` [string]: Full name that identifies the Workspace. This name will appear when people access the Workspace on our platform, for example. Ex: "Stark Bank Workspace"

  ## Options:
    - `:user` [Organization]: Organization struct with nil workspace_id. Only necessary if default organization has not been set in configs.

  ## Return:
    - Workspace struct with updated attributes
  """
  @spec create(user: Organization.t() | nil, username: binary, name: binary) ::
          {:ok, Workspace.t()} | {:error, [Error.t()]}
  def create(parameters \\ []) do
    %{user: user, username: username, name: name} =
      Enum.into(
        parameters |> Check.enforced_keys([:username, :name]),
        %{user: nil}
      )

    Rest.post_single(
      resource(),
      %Workspace{username: username, name: name},
      %{user: user}
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(user: Organization.t() | nil, username: binary, name: binary) :: any
  def create!(parameters \\ []) do
    %{user: user, username: username, name: name} =
      Enum.into(
        parameters |> Check.enforced_keys([:username, :name]),
        %{user: nil, username: nil, name: nil}
      )

    Rest.post_single!(
      resource(),
      %Workspace{username: username, name: name},
      %{user: user}
    )
  end

  @doc """
  Receive a single Workspace struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project]: Organization or Project struct. Only necessary if default project or organization has not been set in configs.

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
      id: json[:id]
    }
  end
end
