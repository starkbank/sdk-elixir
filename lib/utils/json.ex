defmodule StarkBank.Utils.JSON do
  @moduledoc false

  def encode(value) do
    Jason.encode!(value)
  end

  def decode(json) do
    Jason.decode!(json)
  end
end
