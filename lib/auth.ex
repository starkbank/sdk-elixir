defmodule Auth do
  @doc """
  creates a new access-token and invalidates all others

  parameters:
  - env: :sandbox, :production [atom]
  - workspace: workspace name [string]
  - email: email [string]
  - password: password [string]

  returns:
  PID of agent that holds the credentials information, including the access-token
  this PID must be passed as parameter to all SDK calls
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
  recicles the access-token present in the credentials agente

  parameters:
  - credentials: credentials returned by Auth.login [PID]

  returns:
  provided credentials
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
    member_info = body["memberInfo"]
    member_id = member_info["id"]
    workspace_id = member_info["workspaceId"]

    Agent.update(credentials, fn map -> Map.put(map, :access_token, access_token) end)
    Agent.update(credentials, fn map -> Map.put(map, :member_id, member_id) end)
    Agent.update(credentials, fn map -> Map.put(map, :workspace_id, workspace_id) end)

    {:ok, credentials}
  end

  @doc """
  gets the env saved in the credentials agent

  parameters:
  - credentials: credentials returned by Auth.login [PID]

  returns:
  env (:sandbox or :production)
  """
  def get_env(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :env) end)
  end

  @doc """
  gets the workspace saved in the credentials agent

  parameters:
  - credentials: credentials returned by Auth.login [PID]

  returns:
  workspace [string]
  """
  def get_workspace(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :workspace) end)
  end

  @doc """
  gets the email saved in the credentials agent

  parameters:
  - credentials: credentials returned by Auth.login [PID]

  returns:
  email [string]
  """
  def get_email(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :email) end)
  end

  @doc """
  gets the password saved in the credentials agent

  parameters:
  - credentials: credentials returned by Auth.login [PID]

  returns:
  password [string]
  """
  def get_password(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :password) end)
  end

  @doc """
  gets the access_token saved in the credentials agent after login

  parameters:
  - credentials: credentials returned by Auth.login [PID]

  returns:
  access_token [string]
  """
  def get_access_token(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :access_token) end)
  end

  @doc """
  gets the member_id saved in the credentials agent after login

  parameters:
  - credentials: credentials returned by Auth.login [PID]

  returns:
  password [string]
  """
  def get_member_id(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :member_id) end)
  end

  @doc """
  gets the workspace_id saved in the credentials agent after login

  parameters:
  - credentials: credentials returned by Auth.login [PID]

  returns:
  workspace_id [string]
  """
  def get_workspace_id(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :workspace_id) end)
  end
end
