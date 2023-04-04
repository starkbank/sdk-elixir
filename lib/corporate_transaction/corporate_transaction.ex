defmodule StarkBank.CorporateTransaction do
  alias __MODULE__, as: CorporateTransaction
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
    # CorporateTransaction object
  """

  @doc """
  The CorporateTransaction objects created in your Workspace to represent each balance shift.

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when CorporateTransaction is created. ex: "5656565656565656"
    - `:amount` [integer]: CorporateTransaction value in cents. ex: 1234 (= R$ 12.34)
    - `:balance` [integer]: balance amount of the Workspace at the instant of the Transaction in cents. ex: 200 (= R$ 2.00)
    - `:description` [binary]: CorporateTransaction description. ex: "Buying food"
    - `:source` [binary]: source of the transaction. ex: "corporate-purchase/5656565656565656"
    - `:tags` [list of binaries]: list of binaries inherited from the source resource. ex: ["tony", "stark"]
    - `:created` [DateTime]: creation datetime for the CorporateTransaction. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :id,
    :amount,
    :balance,
    :description,
    :source,
    :tags,
    :created
  ]
  defstruct [
    :id,
    :amount,
    :balance,
    :description,
    :source,
    :tags,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single CorporateTransaction object previously created in the Stark Infra API by its id

  ## Parameters (optional):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateTransaction object that corresponds to the given id.
  """
  @spec get(
    id: binary,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, CorporateTransaction.t()} |
    {:error, [Error.t()]}
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
    user: Organization.t() | Project.t() | nil
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Receive a stream of CorporateTransaction objects previously created in the Stark Infra API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:external_ids` [list of binaries, default []]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: "approved", "canceled", "denied", "confirmed" or "voided"
    - `:ids` [list of binaries, default [], default nil]: purchase IDs
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateTransaction objects with updated attributes
  """
  @spec query(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    status: binary | nil,
    ids: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [CorporateTransaction.t()]}} |
    {:error, [Error.t()]}
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
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    status: binary | nil,
    ids: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of CorporateTransaction objects previously created in the Stark Infra API and the cursor to the next page.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:external_ids` [list of binaries, default []]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [binary, default nil]: filter for status of retrieved objects. ex: "approved", "canceled", "denied", "confirmed" or "voided"
    - `:ids` [list of binaries, default [], default nil]: purchase IDs
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateTransaction objects with updated attributes
    - cursor to retrieve the next page of CorporatePurchase objects
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    status: binary | nil,
    ids: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [CorporateTransaction.t()]}} |
    {:error, [Error.t()]}
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
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    tags: [binary] | nil,
    external_ids: [binary] | nil,
    status: binary | nil,
    ids: [binary] | nil,
    user: Organization.t() | Project.t() | nil
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
      "CorporateTransaction",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CorporateTransaction{
      id: json[:id],
      amount: json[:amount],
      balance: json[:balance],
      description: json[:description],
      source: json[:source],
      tags: json[:tags],
      created: json[:created] |> Check.datetime()
    }
  end
end
