defmodule StarkBank.CorporateTransaction do
  alias __MODULE__, as: CorporateTransaction
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups CorporateTransaction related functions
  """

  @doc """
  The CorporateTransaction struct is created in your Workspace to represent each balance shift.

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when CorporateTransaction is created. ex: "5656565656565656"
    - `:amount` [integer, default nil]: CorporateTransaction value in cents. ex: 1234 (= R$ 12.34)
    - `:balance` [integer, default nil]: balance amount of the Workspace at the instant of the Transaction in cents. ex: 200 (= R$ 2.00)
    - `:description` [string, default nil]: CorporateTransaction description. ex: "Buying food"
    - `:source` [string, default nil]: source of the transaction. ex: "corporate-purchase/5656565656565656"
    - `:tags` [list of strings, default nil]: list of strings inherited from the source resource. ex: ["tony", "stark"]
    - `:created` [DateTime, default nil]: creation datetime for the CorporateTransaction. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  defstruct [:id, :amount, :balance, :description, :source, :tags, :created]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single CorporateTransaction struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateTransaction struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, CorporateTransaction.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: CorporateTransaction.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of CorporateTransaction structs previously created in the Stark Bank API

  ## Options:
    - `:source` [string, default nil]: source of the transaction. ex: "corporate-purchase/5656565656565656"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:external_ids` [list of strings, default nil]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateTransaction structs with updated attributes
  """
  @spec query(
          source: binary,
          tags: [binary],
          external_ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          limit: integer,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [CorporateTransaction.t()]}}
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
          source: binary,
          tags: [binary],
          external_ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          limit: integer,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [CorporateTransaction.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CorporateTransaction structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:source` [string, default nil]: source of the transaction. ex: "corporate-purchase/5656565656565656"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:external_ids` [list of strings, default nil]: external IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateTransaction structs with updated attributes and cursor to retrieve the next page of CorporateTransaction objects
  """
  @spec page(
          cursor: binary,
          source: binary,
          tags: [binary],
          external_ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          limit: integer,
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {binary, [CorporateTransaction.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          source: binary,
          tags: [binary],
          external_ids: [binary],
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          limit: integer,
          user: Project.t() | Organization.t()
        ) ::
          [CorporateTransaction.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
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
