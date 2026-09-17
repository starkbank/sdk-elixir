defmodule StarkBank.VerifiedAccount do
  alias __MODULE__, as: VerifiedAccount
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups VerifiedAccount related functions
  """

  @doc """
  When you initialize a VerifiedAccount, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:tax_id` [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"

  ## Parameters (conditionally required):
    - `:bank_code` [string, default nil]: code of the receiver bank institution in Brazil. If an ISPB (8 digits) is informed, a Pix transfer will be created, else a TED will be issued. Required if verifying with bank details. ex: "20018183" or "341"
    - `:branch_code` [string, default nil]: receiver bank account branch. Use '-' in case there is a verifier digit. Required if verifying with bank details. ex: "1357-9"
    - `:key_id` [string, default nil]: pix key identifier. Required if verifying with a Pix key. ex: "tony@starkbank.com", "012.345.678-90"
    - `:name` [string, default nil]: receiver full name. Required if verifying with bank details. ex: "Anthony Edward Stark"
    - `:number` [string, default nil]: receiver bank account number. Use '-' before the verifier digit. Required if verifying with bank details. ex: "876543-2"
    - `:type` [string, default nil]: verified account type. Required if verifying with bank details. ex: "checking", "savings", "salary" or "payment"

  ## Parameters (optional):
    - `:tags` [list of strings, default []]: list of strings for reference when searching for verified accounts. ex: ["employees", "monthly"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when the VerifiedAccount is created. ex: "5656565656565656"
    - `:bank_name` [string, default nil]: bank name associated with the verified account. ex: "Stark Bank"
    - `:status` [string, default nil]: current verified account status. ex: "creating", "created", "processing", "active", "failed" or "canceled"
    - `:created` [DateTime, default nil]: creation datetime for the verified account. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the verified account. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:tax_id]
  defstruct [
    :tax_id,
    :bank_code,
    :branch_code,
    :key_id,
    :name,
    :number,
    :type,
    :tags,
    :id,
    :bank_name,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of VerifiedAccount structs for creation in the Stark Bank API

  ## Parameters (required):
    - `verified_accounts` [list of VerifiedAccount structs]: list of VerifiedAccount structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of VerifiedAccount structs with updated attributes
  """
  @spec create([VerifiedAccount.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [VerifiedAccount.t()]} | {:error, [Error.t()]}
  def create(verified_accounts, options \\ []) do
    Rest.post(
      resource(),
      verified_accounts,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([VerifiedAccount.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(verified_accounts, options \\ []) do
    Rest.post!(
      resource(),
      verified_accounts,
      options
    )
  end

  @doc """
  Receive a single VerifiedAccount struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - VerifiedAccount struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, VerifiedAccount.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: VerifiedAccount.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Cancel a VerifiedAccount entity previously created in the Stark Bank API

  ## Parameters (required):
    - `id` [string]: VerifiedAccount unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled VerifiedAccount struct
  """
  @spec cancel(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, VerifiedAccount.t()} | {:error, [%Error{}]}
  def cancel(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(binary, user: Project.t() | Organization.t() | nil) :: VerifiedAccount.t()
  def cancel!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of VerifiedAccount structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created or updated only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created or updated only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "creating", "created", "processing", "active", "failed" or "canceled"
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of VerifiedAccount structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          ids: [binary],
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [VerifiedAccount.t()]}}
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
          ids: [binary],
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [VerifiedAccount.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 VerifiedAccount structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created or updated only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created or updated only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "creating", "created", "processing", "active", "failed" or "canceled"
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of VerifiedAccount structs with updated attributes and cursor to retrieve the next page of VerifiedAccount objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          ids: [binary],
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {binary, [VerifiedAccount.t()]}} | {:error, [%Error{}]}
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
          ids: [binary],
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          [VerifiedAccount.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "VerifiedAccount",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %VerifiedAccount{
      tax_id: json[:tax_id],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      key_id: json[:key_id],
      name: json[:name],
      number: json[:number],
      type: json[:type],
      tags: json[:tags],
      id: json[:id],
      bank_name: json[:bank_name],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
