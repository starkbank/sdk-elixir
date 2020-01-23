defmodule StarkBank do
  @moduledoc """
  SDK to facilitate Elixir integrations with the Stark Bank API.
  """

  # alias StarkBank.{Charge, Auth}

  def login(env, username, email, password) do
    Auth.login(env, username, email, password)
  end
end
