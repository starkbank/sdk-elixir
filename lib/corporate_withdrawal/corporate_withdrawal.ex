defmodule StarkBank.CorporateWithdrawal do
  alias __MODULE__, as: CorporateWithdrawal
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups CorporateWithdrawal related functions
  """

  @doc """
  The CorporateWithdrawal structs created in your Workspace return cash from your Corporate balance to your
  Banking balance. When you initialize a CorporateWithdrawal, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the struct to the Stark Bank API
  and returns the created struct.

  ## Parameters (required):
    - `:amount` [integer]: CorporateWithdrawal value in cents. Minimum = 0 (any value will be accepted). ex: 1234 (= R$ 12.34)
    - `:external_id` [string]: CorporateWithdrawal external ID. ex: "12345"

  ## Parameters (optional):
    - `:tags` [list of strings, default []]: list of strings for tagging. ex: ["tony", "stark"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when CorporateWithdrawal is created. ex: "5656565656565656"
    - `:transaction_id` [string, default nil]: Stark Bank ledger transaction ids linked to this CorporateWithdrawal
    - `:corporate_transaction_id` [string, default nil]: corporate ledger transaction ids linked to this CorporateWithdrawal
    - `:updated` [DateTime, default nil]: latest update datetime for the CorporateWithdrawal. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:created` [DateTime, default nil]: creation datetime for the CorporateWithdrawal. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:amount, :external_id]
  defstruct [
    :amount,
    :external_id,
    :tags,
    :id,
    :transaction_id,
    :corporate_transaction_id,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a single CorporateWithdrawal struct for creation in the Stark Bank API

  ## Parameters (required):
    - `withdrawal` [CorporateWithdrawal struct]: CorporateWithdrawal struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateWithdrawal struct with updated attributes
  """
  @spec create(CorporateWithdrawal.t() | map, user: Project.t() | Organization.t() | nil) ::
          {:ok, CorporateWithdrawal.t()} | {:error, [Error.t()]}
  def create(withdrawal, options \\ []) do
    Rest.post_single(resource(), withdrawal, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(CorporateWithdrawal.t() | map, user: Project.t() | Organization.t() | nil) :: CorporateWithdrawal.t()
  def create!(withdrawal, options \\ []) do
    Rest.post_single!(resource(), withdrawal, options)
  end

  @doc """
  Receive a single CorporateWithdrawal struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateWithdrawal struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, CorporateWithdrawal.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: CorporateWithdrawal.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of CorporateWithdrawal structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:external_ids` [list of strings, default nil]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateWithdrawal structs with updated attributes
  """
  @spec query(
          limit: integer,
          external_ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [CorporateWithdrawal.t()]}}
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
          external_ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [CorporateWithdrawal.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CorporateWithdrawal structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:external_ids` [list of strings, default nil]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateWithdrawal structs with updated attributes and cursor to retrieve the next page of CorporateWithdrawal objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          external_ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {binary, [CorporateWithdrawal.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          limit: integer,
          external_ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          [CorporateWithdrawal.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "CorporateWithdrawal",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CorporateWithdrawal{
      amount: json[:amount],
      external_id: json[:external_id],
      tags: json[:tags],
      id: json[:id],
      transaction_id: json[:transaction_id],
      corporate_transaction_id: json[:corporate_transaction_id],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
