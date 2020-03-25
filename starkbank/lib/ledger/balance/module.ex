defmodule StarkBank.Balance do

  @moduledoc """
  Groups Balance related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Balance.Data, as: Balance
  alias StarkBank.Project.Data, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Retrieve the Balance entity

  Receive the Balance entity linked to your workspace in the Stark Bank API

  Parameters (optional):
      user [Project entity]: Project entity. Not necessary if starkbank.user was set before function call
  Return:
      Balance entity with updated attributes
  """
  @spec get(Project) :: {:ok, Balance} | {:error, [Error]}
  def get(user) do
    case Rest.get_list(user, %Balance{}) |> Enum.take(1) do
      [{:ok, balance}] -> {:ok, balance}
      [{error_kind, error}] -> {error_kind, error}
    end
  end

  @doc """
  Retrieve the Balance entity

  Receive the Balance entity linked to your workspace in the Stark Bank API

  Parameters (optional):
      user [Project entity]: Project entity. Not necessary if starkbank.user was set before function call
  Return:
      Balance entity with updated attributes
  """
  @spec get!(Project) :: Balance
  def get!(user) do
    {:ok, balance} = get(user)
    balance
  end
end
