defmodule Credentials do
  def login(env, workspace, email, password) do
    {:ok, credentials} = Agent.start_link(fn -> %{} end)

    Agent.update(credentials, fn map -> Map.put(map, :env, env) end)
    Agent.update(credentials, fn map -> Map.put(map, :workspace, workspace) end)
    Agent.update(credentials, fn map -> Map.put(map, :email, email) end)
    Agent.update(credentials, fn map -> Map.put(map, :password, password) end)

    update_access_token(credentials)

    credentials
  end

  def update_access_token(credentials) do
    access_token =
      Requests.post(credentials, 'auth/access-token', %{
        workspace: Agent.get(credentials, fn map -> Map.get(map, :workspace) end),
        email: Agent.get(credentials, fn map -> Map.get(map, :email) end),
        password: Agent.get(credentials, fn map -> Map.get(map, :password) end)
      })

    Agent.update(credentials, fn map -> Map.put(map, :access_token, access_token) end)

    credentials
  end
end
