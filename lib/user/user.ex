defmodule StarkBank.User do
  @moduledoc false

  alias StarkBank.Utils.Check
  defstruct [:environment, :private_key]
  @type t() :: %__MODULE__{}

  def validate(private_key, environment) do
    {
      Check.environment(environment),
      Check.private_key(private_key)
    }
  end
end
