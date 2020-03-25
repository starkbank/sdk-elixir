defmodule StarkBank.Utils.Rest do
  @moduledoc false

  alias StarkBank.Utils.Request, as: Request
  alias StarkBank.Utils.QueryGenerator, as: QueryGenerator
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Utils.JSON, as: JSON

  def get_list(user, resource, limit \\ nil, query \\ %{}) do
    getter = make_getter(user, resource)

    Stream.resource(
      fn ->
        {:ok, pid} = QueryGenerator.start_query(getter, API.last_name_plural(resource), query |> Map.put(:limit, limit))
        pid
      end,
      fn pid ->
        case QueryGenerator.get(pid) do
          :halt -> {:halt, pid}
          {:ok, element} -> {[{:ok, API.from_api_json(element, resource)}], pid}
          {:error, error} -> {[{:error, error}], pid}
        end
      end,
      fn _pid -> nil end
    )
  end

  def get_list!(user, resource, limit \\ nil, query \\ %{}) do
    getter = make_getter(user, resource)

    Stream.resource(
      fn ->
        {:ok, pid} = QueryGenerator.start_query(getter, API.last_name_plural(resource), query |> Map.put(:limit, limit))
        pid
      end,
      fn pid ->
        case QueryGenerator.get(pid) do
          :halt -> {:halt, pid}
          {:ok, element} -> {[API.from_api_json(element, resource)], pid}
          {:error, error} -> raise to_string(error)
        end
      end,
      fn _pid -> nil end
    )
  end

  defp make_getter(user, resource) do
    fn query -> Request.fetch(
        :get,
        API.endpoint(resource),
        user,
        query: query
      ) end
  end

  def get_id(user, resource, id) do
    case Request.fetch(:get, "#{API.endpoint(resource)}/#{id}", user) do
      {:ok, response} -> {:ok, process_single_response(response, resource)}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_id!(user, resource, id) do
    case get_id(user, resource, id) do
      {:ok, entity} -> entity
      {:error, errors} -> raise to_string(errors)
    end
  end

  def get_pdf(user, resource, id) do
    case Request.fetch(:get, "#{API.endpoint(resource)}/#{id}/pdf", user) do
      {:ok, pdf} -> {:ok, pdf}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_pdf!(user, resource, id) do
    case Request.fetch(:get, "#{API.endpoint(resource)}/#{id}/pdf", user) do
      {:ok, pdf} -> pdf
      {:error, errors} -> raise to_string(errors)
    end
  end

  def post(user, resource, entities) do
    case Request.fetch(:post, "#{API.endpoint(resource)}", user, payload: prepare_payload(resource, entities)) do
      {:ok, response} -> {:ok, process_response(resource, response)}
      {:error, errors} -> {:error, errors}
    end
  end

  def post!(user, resource, entities) do
    case post(user, resource, entities) do
      {:ok, entities} -> entities
      {:error, errors} -> raise to_string(errors)
    end
  end

  def post_single(user, resource, entity) do
    case Request.fetch(:post, "#{API.endpoint(resource)}", user, payload: API.api_json(entity)) do
      {:ok, response} -> {:ok, process_single_response(response, resource)}
      {:error, errors} -> {:error, errors}
    end
  end

  def post_single!(user, resource, entity) do
    case post_single(user, resource, entity) do
      {:ok, entity} -> {:ok, entity}
      {:error, errors} -> raise to_string(errors)
    end
  end

  def delete_id(user, resource, id) do
    case Request.fetch(:delete, "#{API.endpoint(resource)}/#{id}", user) do
      {:ok, response} -> {:ok, process_single_response(response, resource)}
      {:error, errors} -> {:error, errors}
    end
  end

  def delete_id!(user, resource, id) do
    case delete_id(user, resource, id) do
      {:ok, entity} -> {:ok, entity}
      {:error, errors} -> raise to_string(errors)
    end
  end

  def patch_id(user, resource, id) do
    case Request.fetch(:patch, "#{API.endpoint(resource)}/#{id}", user) do
      {:ok, response} -> {:ok, process_single_response(response, resource)}
      {:error, errors} -> {:error, errors}
    end
  end

  def patch_id!(user, resource, id) do
    case patch_id(user, resource, id) do
      {:ok, entity} -> entity
      {:error, errors} -> raise to_string(errors)
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
