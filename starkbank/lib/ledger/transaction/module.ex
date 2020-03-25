defmodule StarkBank.Transaction do

  @moduledoc """
  Groups Transaction related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Transaction.Data, as: Transaction
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Create Transactions

  Send a list of Transaction entities for creation in the Stark Bank API

  Parameters (required):
    transactions [list of Transaction entities]: list of Transaction entities to be created in the API
  Parameters (optional):
    user [Project entity]: Project entity. Not necessary if starkbank.user was set before function call
  Return:
    list of Transaction entities with updated attributes
  """
  @spec create(Project.t(), [Transaction.t()]) ::
    {:ok, [Transaction.t()]} | {:error, [Error.t()]}
  def create(user, transactions) do
    Rest.post(
      user,
      resource(),
      transactions
    )
  end

  @doc """
  Create Transactions

  Send a list of Transaction entities for creation in the Stark Bank API

  Parameters (required):
    transactions [list of Transaction entities]: list of Transaction entities to be created in the API
  Parameters (optional):
    user [Project entity]: Project entity. Not necessary if starkbank.user was set before function call
  Return:
    list of Transaction entities with updated attributes
  """
  @spec create!(Project.t(), [Transaction.t()]) :: any
  def create!(user, transactions) do
    Rest.post!(
      user,
      resource(),
      transactions
    )
  end

  @doc """
  Retrieve a specific Transaction

  Receive a single Transaction entity previously created in the Stark Bank API by passing its id

  Parameters (required):
    id [string]: entity unique id. ex: "5656565656565656"
  Parameters (optional):
    user [Project entity]: Project entity. Not necessary if starkbank.user was set before function call
  Return:
    Transaction entity with updated attributes
  """
  @spec get(Project, binary) :: {:ok, Transaction.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Retrieve a specific Transaction

  Receive a single Transaction entity previously created in the Stark Bank API by passing its id

  Parameters (required):
    id [string]: entity unique id. ex: "5656565656565656"
  Parameters (optional):
    user [Project entity]: Project entity. Not necessary if starkbank.user was set before function call
  Return:
    Transaction entity with updated attributes
  """
  @spec get!(Project, binary) :: %Transaction{}
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve Transactions

  Receive a stream of Transaction entities previously created in the Stark Bank API

  Parameters (optional):
    limit [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    external_ids [list of strings, default nil]: list of external ids to filter retrieved entities. ex: ["5656565656565656", "4545454545454545"]
    created_after [Date, default nil] date filter for entities created only after specified date. ex: datetime.date(2020, 3, 10)
    created_before [Date, default nil] date filter for entities created only before specified date. ex: datetime.date(2020, 3, 10)
    user [Project entity, default nil]: Project struct returned from StarkBank.User.project().
  Return:
    stream of Transaction entities with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [Transaction.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, external_ids: external_ids, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, external_ids: nil, created_after: nil, created_before: nil})
    Rest.get_list(user, resource(), limit, %{external_ids: external_ids, after: created_after, before: created_before})
  end

  @doc """
  Retrieve Transactions

  Receive a stream of Transaction entities previously created in the Stark Bank API

  Parameters (optional):
    limit [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    external_ids [list of strings, default nil]: list of external ids to filter retrieved entities. ex: ["5656565656565656", "4545454545454545"]
    created_after [Date, default nil] date filter for entities created only after specified date. ex: datetime.date(2020, 3, 10)
    created_before [Date, default nil] date filter for entities created only before specified date. ex: datetime.date(2020, 3, 10)
    user [Project entity, default nil]: Project struct returned from StarkBank.User.project().
  Return:
    stream of Transaction entities with updated attributes
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [Transaction.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, external_ids: external_ids, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, external_ids: nil, created_after: nil, created_before: nil})
    Rest.get_list!(user, resource(), limit, %{external_ids: external_ids, after: created_after, before: created_before})
  end

  defp resource() do
    %Transaction{amount: nil, description: nil, external_id: nil, receiver_id: nil}
  end
end
