defmodule Auth do
  def login(env, workspace, email, password) do
    {:ok, credentials} = Agent.start_link(fn -> %{} end)

    Agent.update(credentials, fn map -> Map.put(map, :env, env) end)
    Agent.update(credentials, fn map -> Map.put(map, :workspace, workspace) end)
    Agent.update(credentials, fn map -> Map.put(map, :email, email) end)
    Agent.update(credentials, fn map -> Map.put(map, :password, password) end)

    update_access_token(credentials)
  end

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

  def get_env(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :env) end)
  end

  def get_workspace(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :workspace) end)
  end

  def get_email(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :email) end)
  end

  def get_password(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :password) end)
  end

  def get_access_token(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :access_token) end)
  end

  def get_member_id(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :member_id) end)
  end

  def get_workspace_id(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :workspace_id) end)
  end
end
