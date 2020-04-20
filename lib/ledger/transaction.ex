defmodule StarkBank.Transaction do
  alias __MODULE__, as: Transaction
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups Transaction related functions
  """

  @doc """
  A Transaction is a transfer of funds between workspaces inside Stark Bank.
  Transactions created by the user are only for internal transactions.
  Other operations (such as transfer or charge-payment) will automatically
  create a transaction for the user which can be retrieved for the statement.
  When you initialize a Transaction, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:amount` [integer]: amount in cents to be transferred. ex: 1234 (= R$ 12.34)
    - `:description` [string]: text to be displayed in the receiver and the sender statements (Min. 10 characters). ex: "funds redistribution"
    - `:external_id` [string]: unique id, generated by user, to avoid duplicated transactions. ex: "transaction ABC 2020-03-30"
    - `:received_id` [string]: unique id of the receiving workspace. ex: "5656565656565656"

  ## Parameters (optional):
    - `:tags` [list of strings]: list of strings for reference when searching transactions (may be empty). ex: ["abc", "test"]

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when Transaction is created. ex: "7656565656565656"
    - `:sender_id` [string]: unique id of the sending workspace. ex: "5656565656565656"
    - `:fee` [integer, default nil]: fee charged when transfer is created. ex: 200 (= R$ 2.00)
    - `:source` [string, default nil]: locator of the entity that generated the transaction. ex: "charge/18276318736" or "transfer/19381639871263/chargeback"
    - `:created` [DateTime, default nil]: creation datetime for the boleto. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:amount, :description, :external_id, :receiver_id]
  defstruct [
    :amount,
    :description,
    :external_id,
    :receiver_id,
    :sender_id,
    :tags,
    :id,
    :fee,
    :created,
    :source
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of Transaction entities for creation in the Stark Bank API

  ## Parameters (required):
    - `transactions` [list of Transaction entities]: list of Transaction entities to be created in the API

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - list of Transaction structs with updated attributes
  """
  @spec create([Transaction.t()], user: Project.t() | nil) ::
          {:ok, [Transaction.t()]} | {:error, [Error.t()]}
  def create(transactions, options \\ []) do
    Rest.post(
      resource(),
      transactions,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([Transaction.t()], user: Project.t() | nil) :: any
  def create!(transactions, options \\ []) do
    Rest.post!(
      resource(),
      transactions,
      options
    )
  end

  @doc """
  Receive a single Transaction entity previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: entity unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Transaction struct with updated attributes
  """
  @spec get(binary, user: Project.t() | nil) :: {:ok, Transaction.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | nil) :: Transaction.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Transaction entities previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date | string, default nil]: date filter for entities created only after specified date. ex: Date(2020, 3, 10)
    - `:before` [Date | string, default nil]: date filter for entities created only before specified date. ex: Date(2020, 3, 10)
    - `:external_ids` [list of strings, default nil]: list of external ids to filter retrieved entities. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of Transaction structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          external_ids: [binary],
          user: Project.t()
        ) ::
          ({:cont, {:ok, [Transaction.t()]}}
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
          external_ids: [binary],
          user: Project.t()
        ) ::
          ({:cont, [Transaction.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "Transaction",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Transaction{
      amount: json[:amount],
      description: json[:description],
      external_id: json[:external_id],
      receiver_id: json[:receiver_id],
      sender_id: json[:sender_id],
      tags: json[:tags],
      id: json[:id],
      fee: json[:fee],
      created: json[:created] |> Check.datetime(),
      source: json[:source]
    }
  end
end
