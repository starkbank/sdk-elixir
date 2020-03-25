defmodule StarkBank.User do
  alias StarkBank.Utils.Checks, as: Checks
  alias EllipticCurve.PrivateKey, as: PrivateKey
  alias StarkBank.Project.Data, as: Project

  @spec project(:production | :sandbox, binary, binary, binary, [binary] | nil) :: StarkBank.User.Project.t()
  def project(environment, id, private_key, name \\ "", allowed_ips \\ nil) do
    {environment, access_id, private_key} = user("project", id, private_key, environment)
    %Project{
      environment: environment,
      access_id: access_id,
      private_key: private_key,
      name: name,
      allowed_ips: allowed_ips,
    }
  end

  defp user(kind, id, private_key, environment) do
    {:ok, parsed_key} = PrivateKey.fromPem(private_key)
    {
      Checks.check_environment(environment),
      "#{kind}/#{id}",
      parsed_key
    }
  end
end
