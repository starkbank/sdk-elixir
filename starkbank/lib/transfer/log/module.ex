defmodule StarkBank.Transfer.Log do

  @moduledoc """
  Groups TransferLog related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Transfer.Log.Data, as: TransferLog
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Retrieve a specific TransferLog

  Receive a single TransferLog struct previously created by the Stark Bank API by passing its id

  Parameters (required):
    id [string]: struct unique id. ex: "5656565656565656"
  Parameters (optional):
    user [Project struct]: Project struct. Not necessary if starkbank.user was set before function call
  Return:
    TransferLog struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, TransferLog.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: TransferLog.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve TransferLogs

  Receive a generator of TransferLog structs previously created in the Stark Bank API

  Parameters (optional):
    limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    transfer_ids [list of strings, default nil]: list of Transfer ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    types [list of strings, default nil]: filter retrieved structs by types. ex: "success" or "failed"
    user [Project object, default nil]: Project object. Not necessary if starkbank.user was set before function call
  Return:
    list of TransferLog structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [TransferLog.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, transfer_ids: transfer_ids, types: types, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, transfer_ids: nil, types: nil, created_after: nil, created_before: nil})
    Rest.get_list(user, resource(), limit, %{transfer_ids: transfer_ids, types: types, after: created_after, before: created_before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [TransferLog.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, transfer_ids: transfer_ids, types: types, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, transfer_ids: nil, types: nil, created_after: nil, created_before: nil})
    Rest.get_list!(user, resource(), limit, %{transfer_ids: transfer_ids, types: types, after: created_after, before: created_before})
  end

  defp resource() do
    %TransferLog{id: nil, transfer: nil, errors: nil, type: nil, created: nil}
  end
end
