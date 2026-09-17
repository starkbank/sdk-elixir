defmodule StarkBank.VerifiedTransfer do
  alias __MODULE__, as: VerifiedTransfer
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error
  alias StarkBank.Transfer.Rule

  @moduledoc """
  Groups VerifiedTransfer related functions
  """

  @doc """
  When you initialize a VerifiedTransfer, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:amount` [integer]: transfer value in cents. ex: 1234 (= R$ 12.34)
    - `:account_id` [string]: receiver's VerifiedAccount id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:external_id` [string, default nil]: url safe string that must be unique among all your transfers. Duplicated external_ids will cause failures. By default, this parameter will block any transfer that repeats amount and receiver information on the same date. ex: "my-internal-id-123456"
    - `:scheduled` [Date, DateTime or string, default now]: date or datetime when the transfer will be processed. May be pushed to next business day if necessary. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:description` [string, default nil]: optional description to override default description to be shown in the bank statement. ex: "Payment for service #1234"
    - `:display_description` [string, default nil]: optional description to be shown in the receiver bank interface. ex: "Payment for service #1234"
    - `:tags` [list of strings, default []]: list of strings for reference when searching for verified transfers. ex: ["employees", "monthly"]
    - `:rules` [list of Transfer.Rule structs or maps, default []]: list of Transfer.Rule structs for modifying transfer behavior. Passing plain maps (e.g. `%{"key" => "resendingLimit", "value" => 5}`) is still accepted for backwards compatibility; they are hydrated into Transfer.Rule structs on the way back from the API. ex: [%StarkBank.Transfer.Rule{key: "resendingLimit", value: 5}]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the VerifiedTransfer is created. ex: "5656565656565656"
    - `:fee` [integer, default nil]: fee charged when the transfer is created. ex: 200 (= R$ 2.00)
    - `:status` [string, default nil]: current verified transfer status. ex: "created", "processing", "success" or "failed"
    - `:transaction_ids` [list of strings, default nil]: ledger transaction ids linked to this transfer (if there are two, second is the chargeback). ex: ["19827356981273"]
    - `:metadata` [map, default nil]: map used to store additional information about the VerifiedTransfer.
    - `:created` [DateTime, default nil]: creation datetime for the verified transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the verified transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:amount, :account_id]
  defstruct [
    :amount,
    :account_id,
    :external_id,
    :scheduled,
    :description,
    :display_description,
    :tags,
    :rules,
    :id,
    :fee,
    :status,
    :transaction_ids,
    :metadata,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of VerifiedTransfer structs for creation in the Stark Bank API

  ## Parameters (required):
    - `verified_transfers` [list of VerifiedTransfer structs]: list of VerifiedTransfer structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of VerifiedTransfer structs with updated attributes
  """
  @spec create([VerifiedTransfer.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [VerifiedTransfer.t()]} | {:error, [Error.t()]}
  def create(verified_transfers, options \\ []) do
    Rest.post(
      resource(),
      verified_transfers,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([VerifiedTransfer.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(verified_transfers, options \\ []) do
    Rest.post!(
      resource(),
      verified_transfers,
      options
    )
  end

  @doc false
  def resource() do
    {
      "VerifiedTransfer",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %VerifiedTransfer{
      amount: json[:amount],
      account_id: json[:account_id],
      external_id: json[:external_id],
      scheduled: json[:scheduled] |> Check.date_or_datetime(),
      description: json[:description],
      display_description: json[:display_description],
      tags: json[:tags],
      rules: json[:rules] |> Rule.parse_rules(),
      id: json[:id],
      fee: json[:fee],
      status: json[:status],
      transaction_ids: json[:transaction_ids],
      metadata: json[:metadata],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
