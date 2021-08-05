defmodule StarkBank.BoletoHolmes do
  alias __MODULE__, as: BoletoHolmes
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups BoletoHolmes related functions
  """

  @doc """
  When you initialize a BoletoHolmes, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the objects
  to the Stark Bank API and returns the list of created objects.

  ## Parameters (required):
    - `:boleto_id` [string]: unique id of the investigated boleto. ex: "5656565656565656"

  ## Parameters (optional):
    - `:tags` [list of strings]: list of strings for tagging

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when BoletoHolmes is created. ex: "5656565656565656"
    - `:status` [string, default nil]: current BoletoHolmes status. ex: "solving" or "solved"
    - `:result` [string, default nil]: result of boleto status investigation. ex: "paid" or "registered"
    - `:created` [DateTime, default nil]: creation datetime for the BoletoHolmes. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime, default nil]: latest updated datetime for the BoletoHolmes. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [
    :boleto_id
  ]
  defstruct [
    :boleto_id,
    :tags,
    :id,
    :status,
    :result,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of BoletoHolmes objects for creation in the Stark Bank API

  ## Parameters (required):
    - `holmes` [list of BoletoHolmes structs]: list of BoletoHolmes structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BoletoHolmes structs with updated attributes
  """
  @spec create([BoletoHolmes.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [BoletoHolmes.t()]} | {:error, [Error.t()]}
  def create(holmes, options \\ []) do
    Rest.post(
      resource(),
      holmes,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([BoletoHolmes.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(holmes, options \\ []) do
    Rest.post!(
      resource(),
      holmes,
      options
    )
  end

  @doc """
  Receive a single BoletoHolmes struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - BoletoHolmes struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, BoletoHolmes.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: BoletoHolmes.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of BoletoHolmes structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "solving" or "solved"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:boleto_id` [string, default nil]: filter for holmes that investigate a specific boleto by its ID. ex: "5656565656565656"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of BoletoHolmes structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          tags: [binary],
          ids: [binary],
          boleto_id: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [BoletoHolmes.t()]}}
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
          status: binary,
          tags: [binary],
          ids: [binary],
          boleto_id: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [BoletoHolmes.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "BoletoHolmes",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BoletoHolmes{
      boleto_id: json[:boleto_id],
      tags: json[:tags],
      status: json[:status],
      result: json[:result],
      id: json[:id],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
