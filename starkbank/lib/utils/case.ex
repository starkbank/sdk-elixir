defmodule StarkBank.Utils.Case do
  @moduledoc false

  def camel_to_snake(string) do
    Macro.underscore(string)
  end

  def snake_to_camel(string) do
    string
     |> String.graphemes
     |> snake_to_camel_graphemes
     |> Enum.join
  end

  defp snake_to_camel_graphemes([letter | rest]) when letter == "_" do
    snake_to_camel_graphemes([String.upcase(hd(rest)) | tl(rest)])
  end

  defp snake_to_camel_graphemes([letter | rest]) do
    [letter | snake_to_camel_graphemes(rest)]
  end

  defp snake_to_camel_graphemes([]) do
    []
  end

  def camel_to_kebab(string) do
    string
     |> Macro.underscore()
     |> String.replace("_", "-")
  end
end
