defmodule StarkBank.Transfer do
  alias __MODULE__, as: Transfer
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups Transfer related functions
  """

  @doc """
  When you initialize a Transfer, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:amount` [integer]: amount in cents to be transferred. ex: 1234 (= R$ 12.34)
    - `:name` [string]: receiver full name. ex: "Anthony Edward Stark"
    - `:tax_id` [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:bank_code` [string]: 1 to 3 digits of the receiver bank institution in Brazil. ex: "200" or "341"
    - `:branch_code` [string]: receiver bank account branch. Use '-' in case there is a verifier digit. ex: "1357-9"
    - `:account_number` [string]: Receiver Bank Account number. Use '-' before the verifier digit. ex: "876543-2"

  ## Parameters (optional):
    - `:tags` [list of strings]: list of strings for reference when searching for transfers. ex: ["employees", "monthly"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when Transfer is created. ex: "5656565656565656"
    - `:fee` [integer, default nil]: fee charged when transfer is created. ex: 200 (= R$ 2.00)
    - `:status` [string, default nil]: current transfer status. ex: "success" or "failed"
    - `:transaction_ids` [list of strings, default nil]: ledger transaction ids linked to this transfer (if there are two, second is the chargeback). ex: ["19827356981273"]
    - `:created` [DateTime, default nil]: creation datetime for the transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:amount, :name, :tax_id, :bank_code, :branch_code, :account_number]
  defstruct [
    :amount,
    :name,
    :tax_id,
    :bank_code,
    :branch_code,
    :account_number,
    :transaction_ids,
    :fee,
    :tags,
    :status,
    :id,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of Transfer structs for creation in the Stark Bank API

  ## Parameters (required):
    - `transfers` [list of Transfer structs]: list of Transfer structs to be created in the API

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - list of Transfer structs with updated attributes
  """
  @spec create([Transfer.t() | map()], user: Project.t() | nil) ::
          {:ok, [Transfer.t()]} | {:error, [Error.t()]}
  def create(transfers, options \\ []) do
    Rest.post(
      resource(),
      transfers,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([Transfer.t() | map()], user: Project.t() | nil) :: any
  def create!(transfers, options \\ []) do
    Rest.post!(
      resource(),
      transfers,
      options
    )
  end

  @doc """
  Receive a single Transfer struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Transfer struct with updated attributes
  """
  @spec get(binary, user: Project.t() | nil) :: {:ok, Transfer.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | nil) :: Transfer.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a single Transfer pdf receipt file generated in the Stark Bank API by passing its id.
  Only valid for transfers with "processing" or "success" status.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Transfer pdf file content
  """
  @spec pdf(binary, user: Project.t() | nil) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(id, options \\ []) do
    Rest.get_pdf(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(binary, user: Project.t() | nil) :: binary
  def pdf!(id, options \\ []) do
    Rest.get_pdf!(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Receive a stream of Transfer structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date, DateTime or string, default nil]: date filter for structs created or updated only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date, DateTime or string, default nil]: date filter for structs created or updated only before specified date. ex: ~D[2020-03-25]
    - `:transaction_ids` [list of strings, default nil]: list of transaction IDs linked to the desired transfers. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
    - `:sort` [string, default "-created"]: sort order considered in response. Valid options are "created", "-created", "updated" or "-updated".
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of Transfer structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | DateTime.t() | binary,
          before: Date.t() | DateTime.t() | binary,
          transaction_ids: [binary],
          status: binary,
          sort: binary,
          tags: [binary],
          user: Project.t()
        ) ::
          ({:cont, {:ok, [Transfer.t()]}}
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
          transaction_ids: [binary],
          status: binary,
          sort: binary,
          tags: [binary],
          user: Project.t()
        ) ::
          ({:cont, [Transfer.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "Transfer",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Transfer{
      amount: json[:amount],
      name: json[:name],
      tax_id: json[:tax_id],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      account_number: json[:account_number],
      transaction_ids: json[:transaction_ids],
      fee: json[:fee],
      tags: json[:tags],
      status: json[:status],
      id: json[:id],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
