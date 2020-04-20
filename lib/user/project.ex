defmodule StarkBank.User.Project do
  alias __MODULE__, as: Project
  alias StarkBank.User, as: User

  @moduledoc false
  defstruct [:environment, :access_id, :private_key, :name, :allowed_ips]

  def validate(environment, id, private_key, name \\ "", allowed_ips \\ nil) do
    {environment, access_id, private_key} = User.validate("project", id, private_key, environment)

    %Project{
      environment: environment,
      access_id: access_id,
      private_key: private_key,
      name: name,
      allowed_ips: allowed_ips
    }
  end
end
