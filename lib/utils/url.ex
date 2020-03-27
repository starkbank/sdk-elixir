defmodule StarkBank.Utils.URL do

  @moduledoc false

  alias StarkBank.Utils.Case, as: Case

  def get_url(environment, version, path, query) do
    base_url(environment) ++ version ++ '/'
     |> add_path(path)
     |> add_query(query)
  end

  defp base_url(environment) do
    case environment do
      :production -> 'https://api.starkbank.com/'
      :sandbox -> 'https://sandbox.api.starkbank.com/'
    end
  end

  defp add_path(base_url, path) do
    base_url ++ to_charlist(path)
  end

  defp add_query(endpoint, query) when is_nil(query) do
    endpoint
  end

  defp add_query(endpoint, query) do
    list = for {k, v} <- query, !is_nil(v), do: "#{k |> query_key}=#{v |> query_argument}"

    if length(list) > 0 do
      endpoint ++ to_charlist("?" <> String.replace(Enum.join(list, "&"), " ", "%20"))
    else
      endpoint
    end
  end

  defp query_key(key) do
    key
     |> to_string
     |> Case.snake_to_camel
  end

  defp query_argument(value) when is_list(value) or is_tuple(value) do
    value
     |> Enum.map(fn v -> to_string(v) end)
     |> Enum.join(",")
  end

  defp query_argument(value) do
    value
  end
end
