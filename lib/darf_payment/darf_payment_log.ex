defmodule StarkBank.DarfPayment.Log do
  alias __MODULE__, as: Log
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.API
  alias StarkBank.Utils.Check
  alias StarkBank.DarfPayment
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups DarfPayment.Log related functions
  """

  @doc """
  Every time a DarfPayment entity is modified, a corresponding DarfPayment.Log
  is generated for the entity. This log is never generated by the user, but it can
  be retrieved to check additional information on the DarfPayment.

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when payment is created. ex: "5656565656565656"
    - `:payment` [DarfPayment]: DarfPayment entity to which the log refers to.
    - `:errors` [list of strings]: list of errors linked to this DarfPayment event.
    - `:type` [string]: tax type. ex: "das"
    - `:created` [DateTime]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :payment, :errors, :type, :created]
  defstruct [
    :id,
    :payment,
    :errors,
    :type,
    :created,
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single DarfPayment Log struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `:id` [string]: entity unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - DarfPayment Log struct with updated attributes
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
  Receive a stream of DarfPayment Log structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for entities created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for entities created only before specified date. ex: ~D[2020-03-25]
    - `:types` [list of strings, default null]: filter retrieved structs by event types. ex: 'paid' or 'registered'
    - `:payment_ids` [list of strings, default null]: list of DarfPayment ids to filter retrieved structs. ex: ['5656565656565656', '4545454545454545']
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of DarfPayment Log structs with updated attributes
  """
  @spec query(
      limit: integer,
      after: Date.t() | binary,
      before: Date.t() | binary,
      types: [binary],
      payment_ids: [binary],
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
      payment_ids: [binary],
      user: Project.t() | Organization.t()
) ::
    ({:cont, [Log.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 DarfPayment structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for entities created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for entities created only before specified date. ex: ~D[2020-03-25]
    - `:types` [list of strings, default null]: filter retrieved structs by event types. ex: 'paid' or 'registered'
    - `:payment_ids` [list of strings, default null]: list of DarfPayment ids to filter retrieved structs. ex: ['5656565656565656', '4545454545454545']
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DarfPayment Log structs with updated attributes and cursor to retrieve the next page of DarfPayment structs
  """
  @spec page(
      cursor: binary,
      limit: integer,
      after: Date.t() | binary,
      before: Date.t() | binary,
      types: [binary],
      payment_ids: [binary],
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
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    types: [binary],
    payment_ids: [binary],
    user: Project.t() | Organization.t()
  ) ::
      [Log.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "DarfPaymentLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      payment: json[:payment] |> API.from_api_json(&DarfPayment.resource_maker/1),
      errors: json[:errors],
      type: json[:type],
      created: json[:created] |> Check.datetime(),
    }
  end
end
