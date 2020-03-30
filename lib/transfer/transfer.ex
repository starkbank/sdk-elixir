defmodule StarkBank.Transfer do

  alias __MODULE__, as: Transfer
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @moduledoc """
  Groups Transfer related functions

  # Transfer struct:

  When you initialize a Transfer, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - amount [integer]: amount in cents to be transferred. ex: 1234 (= R$ 12.34)
    - name [string]: receiver full name. ex: "Anthony Edward Stark"
    - tax_id [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - bank_code [string]: receiver 1 to 3 digits of the bank institution in Brazil. ex: "200" or "341"
    - branch_code [string]: receiver bank account branch. Use '-' in case there is a verifier digit. ex: "1357-9"
    - account_number [string]: Receiver Bank Account number. Use '-' before the verifier digit. ex: "876543-2"

  ## Parameters (optional):
    - tags [list of strings]: list of strings for reference when searching for transfers. ex: ["employees", "monthly"]

  Attributes (return-only):
    - id [string, default nil]: unique id returned when Transfer is created. ex: "5656565656565656"
    - fee [integer, default nil]: fee charged when transfer is created. ex: 200 (= R$ 2.00)
    - status [string, default nil]: current boleto status. ex: "registered" or "paid"
    - transaction_ids [list of strings, default nil]: ledger transaction ids linked to this transfer (if there are two, second is the chargeback). ex: ["19827356981273"]
    - created [DateTime, default nil]: creation datetime for the transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
    - updated [DateTime, default nil]: latest update datetime for the transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:amount, :name, :tax_id, :bank_code, :branch_code, :account_number]
  defstruct [:amount, :name, :tax_id, :bank_code, :branch_code, :account_number, :transaction_ids, :fee, :tags, :status, :id, :created, :updated]

  @doc """
  # Create Transfers

  Send a list of Transfer structs for creation in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - transfers [list of Transfer structs]: list of Transfer structs to be created in the API

  ## Return:
    - list of Transfer structs with updated attributes
  """
  @spec create(Project.t(), [Transfer.t()]) ::
    {:ok, [Transfer.t()]} | {:error, [Error.t()]}
  def create(user, transfers) do
    Rest.post(
      user,
      resource(),
      transfers
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(Project.t(), [Transfer.t()]) :: any
  def create!(user, transfers) do
    Rest.post!(
      user,
      resource(),
      transfers
    )
  end

  @doc """
  # Retrieve a specific Transfer

  Receive a single Transfer struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - Transfer struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, Transfer.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: Transfer.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  # Retrieve a specific Transfer pdf file

  Receive a single Transfer pdf receipt file generated in the Stark Bank API by passing its id.
  Only valid for transfers with "success" status.

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - Transfer pdf file content
  """
  @spec pdf(Project, binary) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(user, id) do
    Rest.get_pdf(user, resource(), id)
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(Project, binary) :: binary
  def pdf!(user, id) do
    Rest.get_pdf!(user, resource(), id)
  end

  @doc """
  # Retrieve Transfers

  Receive a stream of Transfer structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - status [string, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
    - tags [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - transaction_ids [list of strings, default nil]: list of Transaction ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - after_ [Date, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - before [Date, default nil]: date filter for structs only before specified date. ex: ~D[2020-03-25]
    - sort [string, default "-created"]: sort order considered in response. Valid options are 'created', '-created', 'updated' or '-updated'.

  ## Return:
    - stream of Transfer structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [Transfer.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, transaction_ids: transaction_ids, after_: after_, before: before, sort: sort} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, transaction_ids: nil, after_: nil, before: nil, sort: nil})
    Rest.get_list(user, resource(), limit, %{status: status, tags: tags, transaction_ids: transaction_ids, after: after_, before: before, sort: sort})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [Transfer.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, transaction_ids: transaction_ids, after_: after_, before: before, sort: sort} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, transaction_ids: nil, after_: nil, before: nil, sort: nil})
    Rest.get_list!(user, resource(), limit, %{status: status, tags: tags, transaction_ids: transaction_ids, after: after_, before: before, sort: sort})
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
      created: json[:created] |> Checks.check_datetime,
      updated: json[:updated] |> Checks.check_datetime
    }
  end
end
