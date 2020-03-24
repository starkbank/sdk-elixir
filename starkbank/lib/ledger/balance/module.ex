defmodule StarkBank.Balance do

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Struct.Balance, as: Balance
  alias StarkBank.Struct.Project, as: Project

  @doc """
  Retrieve the Balance object

  Receive the Balance object linked to your workspace in the Stark Bank API

  Parameters (optional):
      user [Project object]: Project object. Not necessary if starkbank.user was set before function call
  Return:
      Balance object with updated attributes
  """
  @spec get(Project) :: {:ok, Balance} | {:error, [map]} | {:internal_error, binary} | {:unknown_error, binary}
  def get(user) do
    case Rest.get_list(user, %Balance{}) |> Enum.take(1) do
      [{:ok, balance}] -> {:ok, balance}
      [{error_kind, error}] -> {error_kind, error}
    end
  end
end
