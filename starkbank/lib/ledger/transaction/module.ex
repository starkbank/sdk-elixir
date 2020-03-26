defmodule StarkBank.Transaction do

  @moduledoc """
  Groups Transaction related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Transaction.Data, as: TransactionData
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Create Transactions

  Send a list of Transaction entities for creation in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    transactions [list of Transaction entities]: list of Transaction entities to be created in the API
  Return:
    list of Transaction entities with updated attributes
  """
  @spec create(Project.t(), [TransactionData.t()]) ::
    {:ok, [TransactionData.t()]} | {:error, [Error.t()]}
  def create(user, transactions) do
    Rest.post(
      user,
      resource(),
      transactions
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(Project.t(), [TransactionData.t()]) :: any
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
    user [Project]: Project struct returned from StarkBank.User.project().
    id [string]: entity unique id. ex: "5656565656565656"
  Return:
    Transaction entity with updated attributes
  """
  @spec get(Project, binary) :: {:ok, TransactionData.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: TransactionData.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve Transactions

  Receive a stream of Transaction entities previously created in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
  Parameters (optional):
    limit [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    external_ids [list of strings, default nil]: list of external ids to filter retrieved entities. ex: ["5656565656565656", "4545454545454545"]
    created_after [Date, default nil] date filter for entities created only after specified date. ex: Date(2020, 3, 10)
    created_before [Date, default nil] date filter for entities created only before specified date. ex: Date(2020, 3, 10)
  Return:
    stream of Transaction entities with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [TransactionData.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, external_ids: external_ids, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, external_ids: nil, created_after: nil, created_before: nil})
    Rest.get_list(user, resource(), limit, %{external_ids: external_ids, after: created_after, before: created_before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [TransactionData.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, external_ids: external_ids, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, external_ids: nil, created_after: nil, created_before: nil})
    Rest.get_list!(user, resource(), limit, %{external_ids: external_ids, after: created_after, before: created_before})
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
    %TransactionData{
      amount: json[:amount],
      description: json[:description],
      external_id: json[:external_id],
      receiver_id: json[:receiver_id],
      sender_id: json[:sender_id],
      tags: json[:tags],
      id: json[:id],
      fee: json[:fee],
      created: json[:created],
      source: json[:source]
    }
  end
end
