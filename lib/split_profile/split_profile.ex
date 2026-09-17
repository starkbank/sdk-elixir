defmodule StarkBank.SplitProfile do
  alias __MODULE__, as: SplitProfile
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups SplitProfile related functions
  """

  @doc """
  When you create a Split, the entity SplitProfile will be automatically created, if
  you haven't create a Split yet, you can use the put method to create your SplitProfile.

  ## Parameters (optional):
    - `:interval` [string, default "week"]: frequency of transfer. Options: "day", "week", "month"
    - `:delay` [DateInterval or integer]: how long the amount will stay at the workspace in milliseconds, ex: 604800
    - `:tags` [list of strings, default []]: list of strings for tagging

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the splitProfile is created. ex: "5656565656565656"
    - `:status` [string, default nil]: current splitProfile status. ex: "created"
    - `:created` [DateTime, default nil]: creation datetime for the splitProfile. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the splitProfile. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:delay, :interval]
  defstruct [
    :interval,
    :delay,
    :tags,
    :id,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Create SplitProfile or update it if you already have it created
  Send a list of SplitProfile structs for creation in the Stark Bank API

  ## Parameters (required):
    - `profiles` [list of SplitProfile structs]: list of SplitProfile structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of SplitProfile structs with updated attributes
  """
  @spec put([SplitProfile.t() | map], user: Project.t() | Organization.t() | nil) ::
          {:ok, [SplitProfile.t()]} | {:error, [Error.t()]}
  def put(profiles, options \\ []) do
    Rest.put(resource(), profiles, options)
  end

  @doc """
  Same as put(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec put!([SplitProfile.t() | map], user: Project.t() | Organization.t() | nil) :: [SplitProfile.t()]
  def put!(profiles, options \\ []) do
    Rest.put!(resource(), profiles, options)
  end

  @doc """
  Receive a single SplitProfile struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - SplitProfile struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, SplitProfile.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: SplitProfile.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of SplitProfile structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created or updated only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created or updated only before specified date. ex: ~D[2020-03-10]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of SplitProfile structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [SplitProfile.t()]}}
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
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [SplitProfile.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 SplitProfile structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-10]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:receiver_ids` [list of strings, default nil]: list of SplitReceiver ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "success"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of SplitProfile structs with updated attributes and cursor to retrieve the next page of SplitProfile objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          ids: [binary],
          receiver_ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [SplitProfile.t()]}} | {:error, [%Error{}]}
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
          ids: [binary],
          receiver_ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
          ) ::
            [SplitProfile.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "SplitProfile",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %SplitProfile{
      interval: json[:interval],
      delay: json[:delay],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
