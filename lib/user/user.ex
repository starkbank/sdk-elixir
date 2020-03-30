defmodule StarkBank.User do
  @moduledoc false

  alias StarkBank.Utils.Checks, as: Checks
  alias EllipticCurve.PrivateKey, as: PrivateKey

  def validate(kind, id, private_key, environment) do
    {:ok, parsed_key} = PrivateKey.fromPem(private_key)
    {
      Checks.check_environment(environment),
      "#{kind}/#{id}",
      parsed_key
    }
  end
end
