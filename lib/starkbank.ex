defmodule StarkBank do
  @moduledoc """
  SDK to facilitate Elixir integrations with the Stark Bank API v2.
  """

  alias StarkBank.Project
  alias StarkBank.Organization
  alias StarkBank.Utils.Check

  @doc """
  The Project object is an authentication entity for the SDK that is permanently
  linked to a specific Workspace.
  All requests to the Stark Bank API must be authenticated via an SDK user,
  which must have been previously created at the Stark Bank website
  [https://web.sandbox.starkbank.com] or [https://web.starkbank.com]
  before you can use it in this SDK. Projects may be passed as the user parameter on
  each request or may be defined as the default user at the start (See README).

  ## Parameters (required):
    - `environment` [string]: environment where the project is being used. ex: "sandbox" or "production"
    - `id` [string]: unique id required to identify project. ex: "5656565656565656"
    - `private_key` [string]: PEM string of the private key linked to the project. ex: "-----BEGIN PUBLIC KEY-----\nMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEyTIHK6jYuik6ktM9FIF3yCEYzpLjO5X/\ntqDioGM+R2RyW0QEo+1DG8BrUf4UXHSvCjtQ0yLppygz23z0yPZYfw==\n-----END PUBLIC KEY-----"
  """
  @spec project(
          environment: :production | :sandbox,
          id: binary,
          private_key: binary
        ) ::
          Project.t()
  def project(parameters) do
    %{environment: environment, id: id, private_key: private_key} =
      Enum.into(
        parameters |> Check.enforced_keys([:environment, :id, :private_key]),
        %{}
      )

    Project.validate(environment, id, private_key)
  end

  @doc """
  The Organization object is an authentication entity for the SDK that
  represents your entire Organization, being able to access any Workspace
  underneath it and even create new Workspaces. Only a legal representative
  of your organization can register or change the Organization credentials.
  All requests to the Stark Bank API must be authenticated via an SDK user,
  which must have been previously created at the Stark Bank website
  [https://web.sandbox.starkbank.com] or [https://web.starkbank.com]
  before you can use it in this SDK. Organizations may be passed as the user parameter on
  each request or may be defined as the default user at the start (See README).
  If you are accessing a specific Workspace using Organization credentials, you should
  specify the workspace ID when building the Organization object or by request, using
  the Organization.replace(organization, workspace_id) method, which creates a copy of the organization
  object with the altered workspace ID. If you are listing or creating new Workspaces, the
  workspace_id should be nil.

  ## Parameters (required):
    - `:environment` [string]: environment where the organization is being used. ex: "sandbox" or "production"
    - `:id` [string]: unique id required to identify organization. ex: "5656565656565656"
    - `:private_key` [EllipticCurve.Organization()]: PEM string of the private key linked to the organization. ex: "-----BEGIN PUBLIC KEY-----\nMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEyTIHK6jYuik6ktM9FIF3yCEYzpLjO5X/\ntqDioGM+R2RyW0QEo+1DG8BrUf4UXHSvCjtQ0yLppygz23z0yPZYfw==\n-----END PUBLIC KEY-----"

  ## Parameters (optional):
    - `:workspace_id` [string]: unique id of the accessed Workspace, if any. ex: nil or "4848484848484848"
  """
  @spec organization(
          environment: :production | :sandbox,
          id: binary,
          private_key: binary,
          workspace_id: binary | nil
        ) ::
          Organization.t()
  def organization(parameters) do
    %{environment: environment, id: id, private_key: private_key, workspace_id: workspace_id} =
      Enum.into(
        parameters |> Check.enforced_keys([:environment, :id, :private_key]),
        %{workspace_id: nil}
      )

    Organization.validate(environment, id, private_key, workspace_id)
  end
end
