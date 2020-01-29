defmodule StarkBank.Auth do
  @moduledoc """
  Used to manage credentials and to create a new session (login) with the StarkBank API

  Functions:
    - login
    - update_access_token
    - logout
    - get_env
    - get_workspace
    - get_email
    - get_access_token
    - get_member_id
    - get_workspace_id
    - get_name
    - get_permissions
  """

  alias StarkBank.Utils.Requests, as: Requests

  @doc """
  Creates a new access-token and invalidates all others

  Parameters:
  - env: :sandbox, :production [atom]
  - workspace: workspace name [string]
  - email: email [string]
  - password: password [string]

  Returns {:ok, credentials}:
  - credentials: PID of agent that holds the credentials information, including the access-token. This PID must be passed as parameter to all SDK calls

  ## Examples

      iex> StarkBank.Auth.login(:sandbox, "workspace", "user@email.com", "password")
      {:ok, #PID<0.178.0>}
  """
  def login(env, workspace, email, password) do
    {:ok, credentials} = Agent.start_link(fn -> %{} end)

    Agent.update(credentials, fn map -> Map.put(map, :env, env) end)
    Agent.update(credentials, fn map -> Map.put(map, :workspace, workspace) end)
    Agent.update(credentials, fn map -> Map.put(map, :email, email) end)
    Agent.update(credentials, fn map -> Map.put(map, :password, password) end)

    update_access_token(credentials)
  end

  @doc """
  Recicles the access-token present in the credentials agente

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns {:ok, credentials}:
  - credentials: PID of agent that holds the credentials information, including the access-token. This PID must be passed as parameter to all SDK calls

  ## Examples

      iex> StarkBank.Auth.update_access_token(credentials)
      {:ok, #PID<0.190.0>}
  """
  def update_access_token(credentials) do
    {:ok, body} =
      Requests.post(credentials, 'auth/access-token', %{
        workspace: get_workspace(credentials),
        email: get_email(credentials),
        password: get_password(credentials),
        platform: "api"
      })

    access_token = body["accessToken"]
    member_info = body["member"]

    member_id = member_info["id"]
    workspace_id = member_info["workspaceId"]
    name = member_info["name"]
    permissions = member_info["permissions"]

    Agent.update(credentials, fn map -> Map.put(map, :access_token, access_token) end)
    Agent.update(credentials, fn map -> Map.put(map, :member_id, member_id) end)
    Agent.update(credentials, fn map -> Map.put(map, :workspace_id, workspace_id) end)
    Agent.update(credentials, fn map -> Map.put(map, :name, name) end)
    Agent.update(credentials, fn map -> Map.put(map, :permissions, permissions) end)

    {:ok, credentials}
  end

  @doc """
  Deletes current session and invalidates current access-token

  Parameters:
  - credentials [PID]: agent PID returned by StarkBank.Auth.login;

  Returns:
  - parsed API response json

  ## Examples

      iex> StarkBank.Auth.logout(credentials)
      {:ok, %{"message" => "Your session has been successfully closed"}}
  """
  def logout(credentials) do
    Requests.delete(
      credentials,
      'auth/access-token/' ++ to_charlist(get_access_token(credentials))
    )
  end

  defp get_password(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :password) end)
  end

  @doc """
  Gets the environment saved in the credentials agent

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns:
  - environment [:sandbox or :production]

  ## Examples

      iex> StarkBank.Auth.get_env(credentials)
      :sandbox
  """
  def get_env(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :env) end)
  end

  @doc """
  Gets the workspace saved in the credentials agent

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns:
  - workspace [string]

  ## Examples

      iex> StarkBank.Auth.get_workspace(credentials)
      "workspace"
  """
  def get_workspace(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :workspace) end)
  end

  @doc """
  Gets the email saved in the credentials agent

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns:
  - email [string]

  ## Examples

      iex> StarkBank.Auth.get_email(credentials)
      "user@email.com"
  """
  def get_email(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :email) end)
  end

  @doc """
  Gets the access_token saved in the credentials agent after login

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns:
  - access_token [string]

  ## Examples

      iex> StarkBank.Auth.get_access_token(credentials)
      "507837650305024057114529712046081608a18e96724397ad149ab182785568cddee9381a714acc903d9e0a5d17ef71"
  """
  def get_access_token(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :access_token) end)
  end

  @doc """
  Gets the member_id saved in the credentials agent after login

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns:
  - password [string]

  ## Examples

      iex> StarkBank.Auth.get_member_id(credentials)
      "5711452971204608"
  """
  def get_member_id(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :member_id) end)
  end

  @doc """
  Gets the workspace_id saved in the credentials agent after login

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns:
  - workspace_id [string]

  ## Examples

      iex> StarkBank.Auth.get_workspace_id(credentials)
      "5078376503050240"
      ""
  """
  def get_workspace_id(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :workspace_id) end)
  end

  @doc """
  Gets the member name saved in the credentials agent after login

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns:
  - name [string]

  ## Examples

      iex> StarkBank.Auth.get_name(credentials)
      "Arya Stark"
  """
  def get_name(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :name) end)
  end

  @doc """
  Gets the user permissions saved in the credentials agent after login

  Parameters:
  - credentials: credentials returned by Auth.login [PID]

  Returns:
  - permissions [list of string]

  ## Examples

      iex> StarkBank.Auth.get_permissions(credentials)
      ["admin"]
  """
  def get_permissions(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :permissions) end)
  end
end
