defmodule StarkBank.User do
  @moduledoc false

  alias StarkBank.Utils.Check

  def validate(kind, id, private_key, environment) do
    {
      Check.environment(environment),
      "#{kind}/#{id}",
      Check.private_key(private_key)
    }
  end
end
