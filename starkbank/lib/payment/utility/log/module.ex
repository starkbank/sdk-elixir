defmodule StarkBank.Payment.Utility.Log do

  @moduledoc """
  Groups UtilityPaymentLog related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Payment.Utility.Log.Data, as: UtilityPaymentLog
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Retrieve a specific UtilityPaymentLog

  Receive a single UtilityPaymentLog struct previously created by the Stark Bank API by passing its id

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    id [string]: struct unique id. ex: "5656565656565656"
  Return:
    UtilityPaymentLog struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, UtilityPaymentLog.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: UtilityPaymentLog.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve UtilityPaymentLogs

  Receive a stream of UtilityPaymentLog structs previously created in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
  Parameters (optional):
    limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    payment_ids [list of strings, default nil]: list of UtilityPayment ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    types [list of strings, default nil]: filter retrieved structs by event types. ex: "paid" or "registered"
  Return:
    stream of UtilityPaymentLog structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [UtilityPaymentLog.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, payment_ids: payment_ids, types: types} =
      Enum.into(options, %{limit: nil, payment_ids: nil, types: nil})
    Rest.get_list(user, resource(), limit, %{payment_ids: payment_ids, types: types})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [UtilityPaymentLog.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, payment_ids: payment_ids, types: types} =
      Enum.into(options, %{limit: nil, payment_ids: nil, types: nil})
    Rest.get_list!(user, resource(), limit, %{payment_ids: payment_ids, types: types})
  end

  defp resource() do
    %UtilityPaymentLog{id: nil, payment: nil, errors: nil, type: nil, created: nil}
  end
end
