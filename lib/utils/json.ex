defmodule StarkBank.Utils.JSON do
  def encode(value) do
    Jason.encode!(value)
  end

  def decode(json) do
    Jason.decode!(json)
  end
end
