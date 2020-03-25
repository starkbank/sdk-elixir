defmodule StarkBank.Transfer do

  @moduledoc """
  Groups Transfer related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Transfer.Data, as: Transfer
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Create Transfers

  Send a list of Transfer structs for creation in the Stark Bank API

  Parameters (required):
    transfers [list of Transfer structs]: list of Transfer structs to be created in the API
  Parameters (optional):
    user [Project struct]: Project struct. Not necessary if starkbank.user was set before function call
  Return:
    list of Transfer structs with updated attributes
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
  Retrieve a specific Transfer

  Receive a single Transfer struct previously created in the Stark Bank API by passing its id

  Parameters (required):
    id [string]: struct unique id. ex: "5656565656565656"
  Parameters (optional):
    user [Project struct]: Project struct. Not necessary if starkbank.user was set before function call
  Return:
    Transfer struct with updated attributes
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
  Retrieve a specific Transfer pdf file

  Receive a single Transfer pdf receipt file generated in the Stark Bank API by passing its id.
  Only valid for transfers with "success" status

  Send a list of Transfer structs for creation in the Stark Bank API

  Parameters (required):
    id [string]: struct unique id. ex: "5656565656565656"
  Parameters (optional):
    user [Project struct]: Project struct. Not necessary if starkbank.user was set before function call
  Return:
    Transfer pdf file
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
  Retrieve Transfers

  Receive a generator of Transfer structs previously created in the Stark Bank API

  Parameters (optional):
    limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    status [string, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
    tags [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    transaction_ids [list of strings, default nil]: list of Transaction ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    after [Date, default nil]: date filter for structs created only after specified date. ex: %Date{}
    before [Date, default nil]: date filter for structs only before specified date. ex: %Date{}
    sort [string, default "-created"]: sort order considered in response. Valid options are 'created', '-created', 'updated' or '-updated'.
    user [Project struct, default nil]: Project struct. Not necessary if starkbank.user was set before function call
  Return:
    generator of Transfer structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [Transfer.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, transaction_ids: transaction_ids, created_after: created_after, created_before: created_before, sort: sort} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, transaction_ids: nil, created_after: nil, created_before: nil, sort: nil})
    Rest.get_list(user, resource(), limit, %{status: status, tags: tags, transaction_ids: transaction_ids, after: created_after, before: created_before, sort: sort})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [Transfer.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, transaction_ids: transaction_ids, created_after: created_after, created_before: created_before, sort: sort} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, transaction_ids: nil, created_after: nil, created_before: nil, sort: nil})
    Rest.get_list!(user, resource(), limit, %{status: status, tags: tags, transaction_ids: transaction_ids, after: created_after, before: created_before, sort: sort})
  end

  defp resource() do
    %Transfer{amount: nil, name: nil, tax_id: nil, bank_code: nil, branch_code: nil, account_number: nil}
  end
end
