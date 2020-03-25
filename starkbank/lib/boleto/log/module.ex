defmodule StarkBank.Boleto.Log do

  @moduledoc """
  Groups BoletoLog related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Boleto.Log.Data, as: BoletoLog
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Retrieve a specific BoletoLog

  Receive a single BoletoLog struct previously created by the Stark Bank API by passing its id

  Parameters (required):
      id [string]: struct unique id. ex: "5656565656565656"
  Parameters (optional):
      user [Project]: Project struct returned from StarkBank.User.project().
  Return:
      BoletoLog struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, BoletoLog.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: BoletoLog.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve BoletoLogs

  Receive a stream of BoletoLog structs previously created in the Stark Bank API

  Parameters (optional):
      limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
      boleto_ids [list of strings, default nil]: list of Boleto ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
      types [list of strings, default nil]: filter for log event types. ex: "paid" or "registered"
      user [Project]: Project struct returned from StarkBank.User.project().
  Return:
      stream of BoletoLog structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [BoletoLog.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, boleto_ids: boleto_ids, types: types, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, boleto_ids: nil, types: nil, created_after: nil, created_before: nil})
    Rest.get_list(user, resource(), limit, %{boleto_ids: boleto_ids, types: types, after: created_after, before: created_before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [BoletoLog.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, boleto_ids: boleto_ids, types: types, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, boleto_ids: nil, types: nil, created_after: nil, created_before: nil})
    Rest.get_list!(user, resource(), limit, %{boleto_ids: boleto_ids, types: types, after: created_after, before: created_before})
  end

  defp resource() do
    %BoletoLog{id: nil, boleto: nil, errors: nil, type: nil, created: nil}
  end
end
