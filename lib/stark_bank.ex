defmodule StarkBank do
  @moduledoc """
  SDK to facilitate Elixir integrations with the Stark Bank API.
  """

  @doc """
  Login.

  ## Examples

      iex> StarkBank.login()
      :world

  """
  def login do
    Credentials.login(:sandbox, "cdottori", "caio.dottori@starkbank.com", "starkstark")
  end
end
