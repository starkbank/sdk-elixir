defmodule StarkBank.Deposit do
  alias __MODULE__, as: Deposit
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups Deposit related functions
  """

  @doc """
  Deposits represent passive cash-ins received by your account from external transfers and payments.

  Attributes (return-only):
    - `:id` [string, default nil]: unique id associated with a Deposit when it is created. ex: "5656565656565656"
    - `:name` [string]: payer name. ex: "Iron Bank S.A."
    - `:tax_id` [string]: payer tax ID (CPF or CNPJ). ex: "012.345.678-90" or "20.018.183/0001-80"
    - `:bank_code` [string]: payer bank code in Brazil. ex: "20018183" or "341"
    - `:branch_code` [string]: payer bank account branch. ex: "1357-9"
    - `:account_number` [string]: payer bank account number. ex: "876543-2"
    - `:account_type` [string]: payer bank account type. ex: "checking"
    - `:amount` [integer]: Deposit value in cents. ex: 1234 (= R$ 12.34)
    - `:type` [string]: Type of settlement that originated the deposit. ex: "pix" or "ted"
    - `:status` [string, default nil]: current Deposit status. ex: "paid" or "registered"
    - `:tags` [list of strings]: list of strings that are tagging the deposit. ex: ["reconciliationId", "txId"]
    - `:fee` [integer, default nil]: fee charged by this deposit. ex: 50 (= R$ 0.50)
    - `:transaction_ids` [list of strings, default nil]: ledger transaction ids linked to this deposit (if there are more than one, all but first are reversals). ex: ["19827356981273"]
    - `:created` [DateTime, default nil]: creation datetime for the Deposit. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime, default nil]:latest update datetime for the Deposit. ex: ~U[2020-08-20 19:32:35.418698Z]
  """
  defstruct [
    :id,
    :name,
    :tax_id,
    :bank_code,
    :branch_code,
    :account_number,
    :account_type,
    :amount,
    :type,
    :status,
    :tags,
    :fee,
    :transaction_ids,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}


  @doc """
  Receive a single Deposit struct from the Stark Bank API by its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Deposit struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Deposit.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Deposit.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a generator of Deposit structs from the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
    - `:sort` [string, default "-created"]: sort order considered in response. Valid options are "created", "-created", "updated" or "-updated".
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of Deposit structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          sort: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [Deposit.t()]}}
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
          sort: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [Deposit.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "Deposit",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Deposit{
      id: json[:id],
      name: json[:name],
      tax_id: json[:tax_id],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      account_number: json[:account_number],
      account_type: json[:account_type],
      amount: json[:amount],
      type: json[:type],
      status: json[:status],
      tags: json[:tags],
      fee: json[:fee],
      transaction_ids: json[:transaction_ids],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
