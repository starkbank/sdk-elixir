defmodule StarkBank do
  @moduledoc """
  SDK to facilitate Elixir integrations with the Stark Bank API v2.
  """

  alias StarkBank.User.Project
  alias StarkBank.Utils.Check

  @doc """
  The Project struct is the main authentication entity for the SDK.
  All requests to the Stark Bank API must be authenticated via a project,
  which must have been previously created at the Stark Bank website
  [https://sandbox.web.starkbank.com] or [https://web.starkbank.com]
  before you can use it in this SDK. Projects may be passed as a parameter on
  each request or may be defined as the default user at the start (See README).

  ## Parameters (required):
    - `environment` [string]: environment where the project is being used. ex: "sandbox" or "production"
    - `id` [string]: unique id required to identify project. ex: "5656565656565656"
    - `private_key` [string]: PEM string of the private key linked to the project. ex: "-----BEGIN PUBLIC KEY-----\nMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEyTIHK6jYuik6ktM9FIF3yCEYzpLjO5X/\ntqDioGM+R2RyW0QEo+1DG8BrUf4UXHSvCjtQ0yLppygz23z0yPZYfw==\n-----END PUBLIC KEY-----"

  ## Attributes (return-only):
    - `name` [string, default ""]: project name. ex: "MyProject"
    - `allowed_ips` [list of strings]: list containing the strings of the ips allowed to make requests on behalf of this project. ex: ["190.190.0.50"]
  """
  @spec project(
          environment: :production | :sandbox,
          id: binary,
          private_key: binary,
          name: binary,
          allowed_ips: [binary] | nil
        ) ::
          StarkBank.User.Project.t()
  def project(parameters) do
    %{environment: environment, id: id, private_key: private_key, name: name, allowed_ips: allowed_ips} =
      Enum.into(
        parameters |> Check.enforced_keys([:environment, :id, :private_key]),
        %{name: "", allowed_ips: []}
      )

    Project.validate(environment, id, private_key, name, allowed_ips)
  end
end
