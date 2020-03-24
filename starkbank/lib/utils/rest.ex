defmodule StarkBank.Utils.Rest do
  @moduledoc false

  alias StarkBank.Utils.Request, as: Request
  alias StarkBank.Utils.QueryGenerator, as: QueryGenerator
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Utils.JSON, as: JSON

  def get_list(user, resource, limit \\ nil, query \\ %{}) do
    query_params = query |> Map.put(:limit, limit) |> Map.put(:cursor, nil)

    getter = fn cursor, limit -> Request.fetch(
        :get,
        API.endpoint(resource),
        user,
        query:
        query_params |> Map.put(:cursor, cursor) |> Map.put(:limit, limit)
      ) end

    Stream.resource(
      fn ->
        {:ok, pid} = QueryGenerator.start_link(getter, limit)
        pid
      end,
      fn pid ->
        case send(pid, self()) do
          :halt -> {:halt, pid}
          {:ok, element} -> {[{:ok, element}], pid}
          {error_kind, error} -> {[{error_kind, error}], pid}
        end
      end,
      fn _pid -> nil end
    )
  end

  def get_id(user, resource, id) do
    case Request.fetch(:get, "#{API.endpoint(resource)}/#{id}", user) do
      {:ok, response} -> {:ok, process_single_response(response, resource)}
      {error_kind, error} -> {error_kind, error}
    end
  end

  def get_pdf(user, resource, id) do
    case Request.fetch(:get, "#{API.endpoint(resource)}/#{id}/pdf", user) do
      {:ok, response} -> {:ok, response}
      {error_kind, error} -> {error_kind, error}
    end
  end

  def post(user, resource, entities) do
    case Request.fetch(:post, "#{API.endpoint(resource)}", user, payload: prepare_payload(resource, entities)) do
      {:ok, response} -> {:ok, process_response(resource, response)}
      {error_kind, error} -> {error_kind, error}
    end
  end

  def post_single(user, resource, entity) do
    case Request.fetch(:post, "#{API.endpoint(resource)}", user, payload: API.api_json(entity)) do
      {:ok, response} -> {:ok, process_single_response(response, resource)}
      {error_kind, error} -> {error_kind, error}
    end
  end

  def delete_id(user, resource, id) do
    case Request.fetch(:delete, "#{API.endpoint(resource)}/#{id}", user) do
      {:ok, response} -> {:ok, process_single_response(response, resource)}
      {error_kind, error} -> {error_kind, error}
    end
  end

  defp process_single_response(response, resource) do
    JSON.decode!(response)[API.last_name(resource)]
     |> API.from_api_json(resource)
  end

  defp prepare_payload(resource, entities) do
    Map.put(%{}, API.last_name_plural(resource), Enum.each(entities, fn entity -> API.api_json(entity) end))
  end

  defp process_response(resource, response) do
    JSON.decode!(response)[API.last_name_plural(resource)]
     |> Enum.each(fn json -> API.from_api_json(json, resource) end)
  end
end
