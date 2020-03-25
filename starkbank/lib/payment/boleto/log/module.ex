defmodule StarkBank.Payment.Boleto.Log do

  @moduledoc """
  Groups BoletoPaymentLog related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Payment.Boleto.Log.Data, as: BoletoPaymentLog
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Retrieve a specific BoletoPaymentLog

  Receive a single BoletoPaymentLog struct previously created by the Stark Bank API by passing its id

  Parameters (required):
    id [string]: struct unique id. ex: "5656565656565656"
  Parameters (optional):
    user [Project]: Project struct returned from StarkBank.User.project().
  Return:
    BoletoPaymentLog struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, BoletoPaymentLog.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: BoletoPaymentLog.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve BoletoPaymentLogs

  Receive a stream of BoletoPaymentLog structs previously created in the Stark Bank API

  Parameters (optional):
    limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    payment_ids [list of strings, default nil]: list of BoletoPayment ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    types [list of strings, default nil]: filter retrieved structs by event types. ex: "paid" or "registered"
    user [Project]: Project struct returned from StarkBank.User.project().
  Return:
    stream of BoletoPaymentLog structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [BoletoPaymentLog.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, payment_ids: payment_ids, types: types} =
      Enum.into(options, %{limit: nil, payment_ids: nil, types: nil})
    Rest.get_list(user, resource(), limit, %{payment_ids: payment_ids, types: types})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [BoletoPaymentLog.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, payment_ids: payment_ids, types: types} =
      Enum.into(options, %{limit: nil, payment_ids: nil, types: nil})
    Rest.get_list!(user, resource(), limit, %{payment_ids: payment_ids, types: types})
  end

  defp resource() do
    %BoletoPaymentLog{id: nil, payment: nil, errors: nil, type: nil, created: nil}
  end
end
