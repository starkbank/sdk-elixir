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

  def from_api_json(json, resource) do
    json
     |> Enum.map(fn({field, value}) -> {field |> Case.camel_to_snake() |> String.to_atom(), value} end)
     |> Enum.filter(fn {field, _value} -> Enum.member?(Map.keys(resource), field) end)
     |> (fn snakes -> struct(resource, snakes) end).()
  end

  def endpoint(resource) do
    resource
     |> resource_to_kebab()
     |> String.replace("-log", "/log")
  end

  def last_name_plural(resource) do
    resource
     |> last_name()
     |> (fn x -> x <> "s" end).()
  end

  def last_name(resource) do
    resource
     |> resource_to_kebab()
     |> String.split("-")
     |> List.last
  end

  defp resource_to_kebab(resource) do
    resource.__struct__
     |> to_string()
     |> String.split(".")
     |> (fn list -> Enum.drop(list, Enum.find_index(list, fn x -> x == "StarkBank" end) + 1) end).()
     |> reverse_payment_order
     |> (fn list -> Enum.take(list, length(list) - 1) end).()
     |> Enum.join("")
     |> Case.camel_to_kebab
  end

  defp reverse_payment_order(["Payment" | [next | rest]]) do
    [next | ["Payment" | rest]]
  end

  defp reverse_payment_order(list) do
    list
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
