defmodule StarkBank.Utils.API do
  @moduledoc false

  alias StarkBank.Utils.Case, as: Case

  def api_json(struct) do
    struct
     |> Map.from_struct()
     |> Enum.filter(fn x -> !is_nil(x) end)
     |> Enum.each(fn({field, value}) -> {Case.snake_to_camel(field), date_to_string(value)} end)
     |> Enum.into(%{})
  end

  defp date_to_string(%Date{} = date) do
    "#{date.year}-#{date.month}-#{date.day}"
  end

  defp date_to_string(%DateTime{} = datetime) do
    "#{datetime.year}-#{datetime.month}-#{datetime.day}"
  end

  defp date_to_string(data) do
    data
  end

  def from_api_json(resource, json) do
    json
     |> Enum.each(fn({field, value}) -> {Case.camel_to_snake(field), value} end)
     |> Enum.filter(fn x -> Enum.member?(Map.keys(resource), x) end)
     |> Enum.into(resource)
  end

  def endpoint(resource) do
    resource
     |> resource_to_kebab()
     |> String.replace("-log", "/log")
  end

  def last_name_plural(resource) do
    resource
     |> last_name()
     |> fn x -> x <> "s" end
  end

  def last_name(resource) do
    resource
     |> resource_to_kebab()
     |> String.split("-")
     |> List.last
  end

  defp resource_to_kebab() do
    resource.__struct__
     |> to_string()
     |> String.split(".")
     |> List.last
     |> Case.camel_to_kebab
  end
end