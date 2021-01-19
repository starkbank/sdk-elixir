defmodule StarkBank.Project do
  alias __MODULE__, as: Project
  alias StarkBank.User

  @moduledoc false
  defstruct [:environment, :id, :access_id, :private_key]

  def validate(environment, id, private_key) do
    {environment, private_key} = User.validate(private_key, environment)

    %Project{
      environment: environment,
      id: id,
      access_id: "project/#{id}",
      private_key: private_key,
    }
  end
end
