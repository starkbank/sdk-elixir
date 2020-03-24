defmodule StarkBank.Utils.Rest do
  @moduledoc false

  alias StarkBank.Utils.Request, as: Request
  alias StarkBank.Utils.QueryGenerator, as: QueryGenerator
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Utils.JSON, as: JSON

  def get_list(user, resource, limit \\ 100, query \\ %{}) do
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
      {:ok, response} -> {:ok, JSON.decode!(response)[API.last_name(resource)] |> API.from_api_json(resource)}
      {error_kind, error} -> {error_kind, error}
    end
  end

  def get_pdf(user, resource, id) do
    case Request.fetch(:get, "#{API.endpoint(resource)}/#{id}/pdf", user) do
      {:ok, response} -> {:ok, response}
      {error_kind, error} -> {error_kind, error}
    end
  end
end
