defmodule StarkBank.User do
  @moduledoc false

  alias StarkBank.Utils.Check

  def validate(private_key, environment) do
    {
      Check.environment(environment),
      Check.private_key(private_key)
    }
  end
end
