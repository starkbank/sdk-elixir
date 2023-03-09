defmodule StarkBank.BoletoHolmes.Log do
  alias __MODULE__, as: Log
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.API
  alias StarkBank.BoletoHolmes
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups BoletoHolmes.Log related functions
  """

  @doc """
  Every time a BoletoHolmes entity is updated, a corresponding BoletoHolmes.Log
  is generated for the entity. This log is never generated by the
  user, but it can be retrieved to check additional information
  on the BoletoHolmes.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when the log is created. ex: "5656565656565656"
    - `:holmes` [BoletoHolmes]: BoletoHolmes entity to which the log refers to.
    - `:type` [string]: type of the BoletoHolmes event which triggered the log creation. ex: "solving" or "solved"
    - `:created` [DateTime]: creation datetime for the log. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime]: latest update datetime for the log. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [
    :id,
    :holmes,
    :type,
    :created,
    :updated
]
  defstruct [
    :id,
    :holmes,
    :type,
    :created,
    :updated
]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single Log struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Log struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Log.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Log.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Log structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:types` [list of strings, default nil]: filter for log event types. ex: "paid" or "registered"
    - `:holmes_ids` [list of strings, default nil]: list of BoletoHolmes ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of Log structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          types: [binary],
          holmes_ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [Log.t()]}}
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
          types: [binary],
          holmes_ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [Log.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 BoletoHolmes.Log objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:types` [list of strings, default nil]: filter for log event types. ex: "paid" or "registered"
    - `:holmes_ids` [list of strings, default nil]: list of BoletoHolmes ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BoletoHolmes.Log structs with updated attributes and cursor to retrieve the next page of BoletoHolmes.Log objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          types: [binary],
          holmes_ids: [binary],
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [Log.t()]}} | {:error, [%Error{}]}
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
          types: [binary],
          holmes_ids: [binary],
          user: Project.t() | Organization.t()
          ) ::
            [Log.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "BoletoHolmesLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      holmes: json[:holmes] |> API.from_api_json(&BoletoHolmes.resource_maker/1),
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime(),
      type: json[:type]
    }
  end
end
