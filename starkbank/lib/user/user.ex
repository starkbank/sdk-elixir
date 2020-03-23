defmodule StarkBank.User do
  @moduledoc false

  def project(id, environment, private_key, name \\ "", allowed_ips \\ nil) do
    {environment, access_id, private_key} = user("project", id, private_key, environment)
    %StarkBank.User.Project{
      environment: environment,
      access_id: access_id,
      private_key: private_key,
      name: name,
      allowed_ips: allowed_ips,
    }
  end

  defp user(kind, id, private_key, environment) do
    {
      StarkBank.Utils.Checks.check_environment(environment),
      "#{kind}/#{id}",
      EllipticCurve.PrivateKey.fromPem(private_key)
    }
  end
end
