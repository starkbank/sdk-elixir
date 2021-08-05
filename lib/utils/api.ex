defmodule StarkBank.Utils.API do
  @moduledoc false

  alias StarkBank.Utils.Case

  def api_json(%{__struct__: _} = struct) do
    struct
    |> Map.from_struct()
    |> api_json()
  end

  def api_json(map) when is_map(map) do
    map
    |> cast_json_to_api_format()
  end

  def cast_json_to_api_format(map) when is_map(map) do
    map
    |> Enum.filter(fn {_field, value} -> !is_nil(value) end)
    |> Enum.map(fn {field, value} ->
      {Case.snake_to_camel(to_string(field)), coerce_types(value)}
    end)
    |> Enum.into(%{})
  end

  def cast_json_to_api_format(list) when is_list(list) do
    list
    |> Enum.map(fn value -> cast_json_to_api_format(value) end)
  end

  def cast_json_to_api_format(value) do
    value
  end

  defp coerce_types(list) when is_list(list) do
    cast_json_to_api_format(list)
  end

  defp coerce_types(%Date{} = date) do
    "#{date.year}-#{date.month}-#{date.day}"
  end

  defp coerce_types(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_iso8601()
    |> String.replace("Z", "+00:00")
  end

  defp coerce_types(%{__struct__: _} = struct) do
    api_json(struct)
  end

  defp coerce_types(value) do
    value
  end

  def from_api_json(json, resource_maker) do
    json
    |> Enum.map(fn {field, value} ->
      {field |> Case.camel_to_snake() |> String.to_atom(), value}
    end)
    |> resource_maker.()
  end

  def endpoint(resource_name) do
    resource_name
    |> Case.camel_to_kebab()
    |> String.replace("-log", "/log")
    |> String.replace("-attempt", "/attempt")
  end

  def last_name_plural(resource_name) do
    word = resource_name |> last_name()

    cond do
      word |> String.ends_with?("s") ->
        word
      word |> String.ends_with?("ey") ->
        word <> "s"
      word |> String.ends_with?("y") ->
        (word |> String.slice(0..-2)) <> "ies"
      true -> word <> "s"
    end
  end

  def last_name(resource_name) do
    resource_name
    |> Case.camel_to_kebab()
    |> String.split("-")
    |> List.last()
  end

  def errors_to_string(errors) do
    errors
    |> Enum.map(&Map.from_struct/1)
    |> Enum.map(&map_to_string/1)
    |> to_string()
  end

  defp map_to_string(map) do
    map
    |> Map.keys()
    |> Enum.map(fn key -> "#{key}: #{map[key]}" end)
    |> Enum.join(", ")
    |> (fn s -> "{#{s}}" end).()
  end
end
