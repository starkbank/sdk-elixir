defmodule StarkBank.CorporatePurchase.Log do
  alias __MODULE__, as: Log
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
    # CorporatePurchase.Log object
  """

  @doc """
  Every time an CorporatePurchase entity is updated, a corresponding CorporatePurchase.Log
  is generated for the entity. This log is never generated by the
  user, but it can be retrieved to check additional information
  on the CorporatePurchase.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when the log is created. ex: "5656565656565656"
    - `:purchase` [CorporatePurchase]: CorporatePurchase entity to which the log refers to.
    - `:corporate_transaction_id` [binary]: transaction ID related to the CorporateCard.
    - `:description` [string]: purchase descriptions. ex: "my_description"
    - `:errors` [list of binaries]: list of errors linked to this CorporatePurchase event
    - `:type` [binary]: type of the CorporatePurchase event which triggered the log creation. Options: "approved", "canceled", "confirmed", "denied", "reversed", "voided".
    - `:created` [DateTime]: creation datetime for the log. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :purchase,
    :corporate_transaction_id,
    :description,
    :errors,
    :type,
    :created
  ]
  defstruct [
    :id,
    :purchase,
    :corporate_transaction_id,
    :description,
    :errors,
    :type,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single CorporatePurchase.Log object previously created by the Stark Bank API by its id

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporatePurchase.Log object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, Log.t() } |
    { :error, [Error.t()] }
  def get(id, options \\ []) do
    Rest.get_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    id: binary,
    user: Project.t() | Organization.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of CorporatePurchase.Log objects previously created in the Stark Bank API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:types` [list of binaries, default nil]: filter for log event types. ex: ["approved", "canceled", "confirmed", "denied", "reversed", "voided"]
    - `:purchase_ids` [list of binaries, default nil]: list of Purchase ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of binaries, default nil]: list of CorporatePurchase ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporatePurchase.Log objects with updated attributes
  """
  @spec query(
    ids: [binary],
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    types: [binary],
    purchase_ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) ::
    {:ok, {binary, [Log.t()]} } |
    { :error, [Error.t()] }
  def query(options \\ []) do
    Rest.get_list(
      resource(),
      options
    )
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    types: [binary],
    purchase_ids: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 CorporatePurchase.Log objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:types` [list of binaries, default nil]: filter for log event types. ex: ["approved", "canceled", "confirmed", "denied", "reversed", "voided"]
    - `:purchase_ids` [list of binaries, default nil]: list of Purchase ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of binaries, default nil]: list of CorporatePurchase ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporatePurchase.Log objects with updated attributes
    - cursor to retrieve the next page of CorporatePurchase.Log objects
  """
  @spec page(
    cursor: binary,
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    types: [binary],
    purchase_ids: [binary],
    ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: {:ok, {binary, [Log.t()]} } | { :error, [Error.t()] }
  def page(options \\ []) do
    Rest.get_page(
      resource(),
      options
    )
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary,
    ids: [binary],
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    types: [binary],
    purchase_ids: [binary],
    user: Project.t() | Organization.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc false
  def resource() do
    {
      "CorporatePurchaseLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      purchase: json[:purchase],
      corporate_transaction_id: json[:corporate_transaction_id],
      description: json[:description],
      errors: json[:errors],
      type: json[:type],
      created: json[:created] |> Check.datetime(),
    }
  end
end
