defmodule StarkBank.User do
  @moduledoc false

  alias StarkBank.Utils.Checks, as: Checks

  def validate(kind, id, private_key, environment) do
    {
      Checks.check_environment(environment),
      "#{kind}/#{id}",
      Checks.check_private_key(private_key)
    }
  end
end
