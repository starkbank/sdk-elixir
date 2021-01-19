defmodule StarkBank.Organization do
  alias __MODULE__, as: Organization
  alias StarkBank.User

  @moduledoc false
  defstruct [:environment, :id, :access_id, :private_key, :workspace_id]

  def validate(environment, id, private_key, workspace_id) do
    {environment, private_key} = User.validate(private_key, environment)

    %Organization{
      environment: environment,
      id: id,
      access_id: access_id(id, workspace_id),
      private_key: private_key,
      workspace_id: workspace_id,
    }
  end

  def replace(organization, workspace_id) do
    %Organization{
      environment: organization.environment,
      id: organization.id,
      access_id: access_id(organization.id, workspace_id),
      private_key: organization.private_key,
      workspace_id: workspace_id,
    }
  end

  defp access_id(id, workspace_id) when is_nil(workspace_id) do
    "organization/#{id}"
  end

  defp access_id(id, workspace_id) do
    "organization/#{id}/workspace/#{workspace_id}"
  end
end
