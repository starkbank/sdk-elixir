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
      user [Project]: Project struct returned from StarkBank.User.project().
  Return:
      Balance entity with updated attributes
  """
  @spec get(Project) :: {:ok, Balance} | {:error, [Error]}
  def get(user) do
    case Rest.get_list(user, %Balance{}) |> Enum.take(1) do
      [{:ok, balance}] -> {:ok, balance}
      [{:error, error}] -> {:error, error}
    end
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project) :: Balance
  def get!(user) do
    {:ok, balance} = get(user)
    balance
  end
end
