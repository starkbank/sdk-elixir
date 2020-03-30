defmodule StarkBank.Balance do

  @moduledoc """
  Groups Balance related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Balance.Data, as: BalanceData
  alias StarkBank.User.Project.Data, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  # Retrieve the Balance entity

  Receive the Balance entity linked to your workspace in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Return:
    - Balance struct with updated attributes
  """
  @spec get(Project) :: {:ok, BalanceData.t()} | {:error, [Error]}
  def get(user) do
    case Rest.get_list(user, resource()) |> Enum.take(1) do
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

  @doc false
  def resource() do
    {
      "Balance",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BalanceData{
      id: json[:id],
      amount: json[:amount],
      currency: json[:currency],
      updated: json[:updated] |> Checks.check_datetime
    }
  end
end
