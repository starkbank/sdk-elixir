defmodule JSON do
  def encode(map) do
    list = for {k, v} <- map, do: "\"#{k}\":\"#{v}\""
    to_charlist("{" <> Enum.join(list, ", ") <> "}")
  end

  def decode(json) do
    {decoded, _} =
      json
      |> to_string
      |> String.replace("{", "%{")
      |> String.replace("null", "nil")
      |> String.replace("\":", ":")
      |> String.replace(", \"", ", ")
      |> String.replace("{\"", "{")
      |> String.replace("null", "nil")
      |> Code.eval_string()

    decoded
  end
end
