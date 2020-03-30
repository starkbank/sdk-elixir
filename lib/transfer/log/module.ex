defmodule StarkBank.Transfer.Log do

  @moduledoc """
  Groups TransferLog related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Transfer.Log.Data, as: TransferLog
  alias StarkBank.Transfer, as: Transfer
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  # Retrieve a specific TransferLog

  Receive a single TransferLog struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.User.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - TransferLog struct with updated attributes
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
  # Retrieve TransferLogs

  Receive a stream of TransferLog structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.User.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - transfer_ids [list of strings, default nil]: list of Transfer ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - types [list of strings, default nil]: filter retrieved structs by types. ex: "success" or "failed"
    - after_ [Date, default nil] date filter for structs created only after specified date. ex: Date(2020, 3, 10)
    - before [Date, default nil] date filter for structs only before specified date. ex: Date(2020, 3, 10)

  ## Return:
    - stream of TransferLog structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [TransferLog.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, transfer_ids: transfer_ids, types: types, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, transfer_ids: nil, types: nil, after_: nil, before: nil})
    Rest.get_list(user, resource(), limit, %{transfer_ids: transfer_ids, types: types, after: after_, before: before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [TransferLog.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, transfer_ids: transfer_ids, types: types, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, transfer_ids: nil, types: nil, after_: nil, before: nil})
    Rest.get_list!(user, resource(), limit, %{transfer_ids: transfer_ids, types: types, after: after_, before: before})
  end

  @doc false
  def resource() do
    {
      "TransferLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %TransferLog{
      id: json[:id],
      transfer: json[:transfer] |> API.from_api_json(&Transfer.resource_maker/1),
      created: json[:created] |> Checks.check_datetime,
      type: json[:type],
      errors: json[:errors]
    }
  end
end
