defmodule StarkBank.Utils.API do
  @moduledoc false

  alias StarkBank.Utils.Case, as: Case

  def api_json(struct) do
    struct
     |> Map.from_struct()
     |> Enum.filter(fn {_field, value} -> !is_nil(value) end)
     |> Enum.map(fn {field, value} -> {Case.snake_to_camel(to_string(field)), date_to_string(value)} end)
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

  def from_api_json(json, resource_maker) do
    json
     |> Enum.map(fn({field, value}) -> {field |> Case.camel_to_snake() |> String.to_atom(), value} end)
     |> resource_maker.()
  end

  def endpoint(resource_name) do
    resource_name
     |> Case.camel_to_kebab
     |> String.replace("-log", "/log")
  end

  def last_name_plural(resource_name) do
    resource_name
     |> last_name
     |> (fn x -> x <> "s" end).()
  end

  def last_name(resource_name) do
    resource_name
     |> Case.camel_to_kebab
     |> String.split("-")
     |> List.last
  end

  def errors_to_string(errors) do
    errors
     |> Enum.map(&Map.from_struct/1)
     |> Enum.map(&map_to_string/1)
     |> to_string
  end

  defp map_to_string(map) do
    map
     |> Map.keys
     |> Enum.map(fn key -> "#{key}: #{map[key]}" end)
     |> Enum.join(", ")
     |> (fn s -> "{#{s}}" end).()
  end
end
