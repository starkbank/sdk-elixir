defmodule StarkBank.Boleto.Log do
  alias __MODULE__, as: Log
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.API
  alias StarkBank.Boleto
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups Boleto.Log related functions
  """

  @doc """
  Every time a Boleto entity is updated, a corresponding Boleto.Log
  is generated for the entity. This log is never generated by the
  user, but it can be retrieved to check additional information
  on the Boleto.

  ## Attributes:
    - `:id` [string]: unique id returned when the log is created. ex: "5656565656565656"
    - `:boleto` [Boleto]: Boleto entity to which the log refers to.
    - `:errors` [list of strings]: list of errors linked to this Boleto event
    - `:type` [string]: type of the Boleto event which triggered the log creation. ex: "registered" or "paid"
    - `:created` [DateTime]: creation datetime for the log. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :boleto, :errors, :type, :created]
  defstruct [:id, :boleto, :errors, :type, :created]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single Log struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Log struct with updated attributes
  """
  @spec get(binary, user: Project.t() | nil) :: {:ok, Log.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | nil) :: Log.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Log structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date, DateTime or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date, DateTime or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:types` [list of strings, default nil]: filter for log event types. ex: "paid" or "registered"
    - `:boleto_ids` [list of strings, default nil]: list of Boleto ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of Log structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | DateTime.t() | binary,
          before: Date.t() | DateTime.t() | binary,
          types: [binary],
          boleto_ids: [binary],
          user: Project.t()
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
          after: Date.t() | DateTime.t() | binary,
          before: Date.t() | DateTime.t() | binary,
          types: [binary],
          boleto_ids: [binary],
          user: Project.t()
        ) ::
          ({:cont, [Log.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "BoletoLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      boleto: json[:boleto] |> API.from_api_json(&Boleto.resource_maker/1),
      created: json[:created] |> Check.datetime(),
      type: json[:type],
      errors: json[:errors]
    }
  end
end
