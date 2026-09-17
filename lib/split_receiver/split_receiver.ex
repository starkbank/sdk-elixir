defmodule StarkBank.SplitReceiver do
  alias __MODULE__, as: SplitReceiver
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups SplitReceiver related functions
  """

  @doc """
  When you initialize a SplitReceiver struct, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:name` [string]: receiver full name. ex: "Anthony Edward Stark"
    - `:tax_id` [string]: receiver account tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:bank_code` [string]: code of the receiver bank institution in Brazil. If an ISPB (8 digits) is informed, a PIX splitReceiver will be created, else a TED will be issued. ex: "20018183" or "341"
    - `:branch_code` [string]: receiver bank account branch. Use '-' in case there is a verifier digit. ex: "1357-9"
    - `:account_number` [string]: receiver bank account number. Use '-' before the verifier digit. ex: "876543-2"
    - `:account_type` [string]: Receiver bank account type. This parameter only has effect on Pix SplitReceivers. ex: "checking", "savings", "salary" or "payment"

  ## Parameters (optional):
    - `:tags` [list of strings, default []]: list of strings for reference when searching for receivers. ex: ["seller/123456"]

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the splitReceiver is created. ex: "5656565656565656"
    - `:status` [string, default nil]: current splitReceiver status. ex: "success" or "failed"
    - `:created` [DateTime, default nil]: creation datetime for the splitReceiver. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the splitReceiver. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:name, :tax_id, :bank_code, :branch_code, :account_number, :account_type]
  defstruct [
    :name,
    :tax_id,
    :bank_code,
    :branch_code,
    :account_number,
    :account_type,
    :tags,
    :id,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of SplitReceiver structs for creation in the Stark Bank API

  ## Parameters (required):
    - `receivers` [list of SplitReceiver structs]: list of SplitReceiver structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of SplitReceiver structs with updated attributes
  """
  @spec create([SplitReceiver.t() | map], user: Project.t() | Organization.t() | nil) ::
          {:ok, [SplitReceiver.t()]} | {:error, [Error.t()]}
  def create(receivers, options \\ []) do
    Rest.post(resource(), receivers, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([SplitReceiver.t() | map], user: Project.t() | Organization.t() | nil) :: [SplitReceiver.t()]
  def create!(receivers, options \\ []) do
    Rest.post!(resource(), receivers, options)
  end

  @doc """
  Receive a single SplitReceiver struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - SplitReceiver struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, SplitReceiver.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: SplitReceiver.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of SplitReceiver structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created or updated only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created or updated only before specified date. ex: ~D[2020-03-10]
    - `:transaction_ids` [list of strings, default nil]: list of transaction IDs linked to the desired splitReceivers. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "success" or "failed"
    - `:tax_id` [string, default nil]: filter for splitReceivers sent to the specified tax ID. ex: "012.345.678-90"
    - `:sort` [string, default "-created"]: sort order considered in response. Valid options are "created", "-created", "updated" or "-updated".
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of SplitReceiver structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          transaction_ids: [binary],
          status: binary,
          tax_id: binary,
          sort: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [SplitReceiver.t()]}}
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
          transaction_ids: [binary],
          status: binary,
          tax_id: binary,
          sort: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [SplitReceiver.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 SplitReceiver structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created or updated only after specified date. ex: ~D[2020-03-10]
    - `:before` [Date or string, default nil]: date filter for structs created or updated only before specified date. ex: ~D[2020-03-10]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "success" or "failed"
    - `:sort` [string, default "-created"]: sort order considered in response. Valid options are "created", "-created", "updated" or "-updated".
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of SplitReceiver structs with updated attributes and cursor to retrieve the next page of SplitReceiver objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          sort: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [SplitReceiver.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          sort: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
          ) ::
            [SplitReceiver.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "SplitReceiver",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %SplitReceiver{
      name: json[:name],
      tax_id: json[:tax_id],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      account_number: json[:account_number],
      account_type: json[:account_type],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
