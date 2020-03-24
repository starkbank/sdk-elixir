defmodule StarkBank.Utils.Case do
  @moduledoc false

  def camel_to_snake(string) do
    Macro.underscore(string)
  end

  def snake_to_camel(string) do
    Macro.camelize(string)
  end

  def camel_to_kebab(string) do
    string
     |> Macro.underscore()
     |> String.replace("_", "-")
  end
end
