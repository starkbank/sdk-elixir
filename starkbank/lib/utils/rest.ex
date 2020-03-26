defmodule StarkBank.Utils.Rest do
  @moduledoc false

  alias StarkBank.Utils.Request, as: Request
  alias StarkBank.Utils.QueryGenerator, as: QueryGenerator
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Utils.JSON, as: JSON

  def get_list(user, {resource_name, resource_maker}, limit \\ nil, query \\ %{}) do
    getter = make_getter(user, resource_name)

    Stream.resource(
      fn ->
        {:ok, pid} = QueryGenerator.start_query(getter, API.last_name_plural(resource_name), query |> Map.put(:limit, limit))
        pid
      end,
      fn pid ->
        case QueryGenerator.get(pid) do
          :halt -> {:halt, pid}
          {:ok, element} -> {[{:ok, API.from_api_json(element, resource_maker)}], pid}
          {:error, error} -> {[{:error, error}], pid}
        end
      end,
      fn _pid -> nil end
    )
  end

  def get_list!(user, {resource_name, resource_maker}, limit \\ nil, query \\ %{}) do
    getter = make_getter(user, resource_name)

    Stream.resource(
      fn ->
        {:ok, pid} = QueryGenerator.start_query(getter, API.last_name_plural(resource_name), query |> Map.put(:limit, limit))
        pid
      end,
      fn pid ->
        case QueryGenerator.get(pid) do
          :halt -> {:halt, pid}
          {:ok, element} -> {[API.from_api_json(element, resource_maker)], pid}
          {:error, errors} -> raise API.errors_to_string(errors)
        end
      end,
      fn _pid -> nil end
    )
  end

  defp make_getter(user, resource_name) do
    fn query -> Request.fetch(
        :get,
        API.endpoint(resource_name),
        user,
        query: query
      )
    end
  end

  def get_id(user, {resource_name, resource_maker}, id) do
    case Request.fetch(:get, "#{API.endpoint(resource_name)}/#{id}", user) do
      {:ok, response} -> {:ok, process_single_response(response, resource_name, resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_id!(user, {resource_name, resource_maker}, id) do
    case get_id(user, {resource_name, resource_maker}, id) do
      {:ok, entity} -> entity
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def get_pdf(user, {resource_name, _resource_maker}, id) do
    case Request.fetch(:get, "#{API.endpoint(resource_name)}/#{id}/pdf", user) do
      {:ok, pdf} -> {:ok, pdf}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_pdf!(user, {resource_name, _resource_maker}, id) do
    case Request.fetch(:get, "#{API.endpoint(resource_name)}/#{id}/pdf", user) do
      {:ok, pdf} -> pdf
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def post(user, {resource_name, resource_maker}, entities) do
    case Request.fetch(:post, "#{API.endpoint(resource_name)}", user, payload: prepare_payload(resource_name, entities)) do
      {:ok, response} -> {:ok, process_response(resource_name, resource_maker, response)}
      {:error, errors} -> {:error, errors}
    end
  end

  def post!(user, {resource_name, resource_maker}, entities) do
    case post(user, {resource_name, resource_maker}, entities) do
      {:ok, entities} -> entities
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def post_single(user, {resource_name, resource_maker}, entity) do
    case Request.fetch(:post, "#{API.endpoint(resource_name)}", user, payload: API.api_json(entity)) do
      {:ok, response} -> {:ok, process_single_response(response, resource_name, resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def post_single!(user, {resource_name, resource_maker}, entity) do
    case post_single(user, {resource_name, resource_maker}, entity) do
      {:ok, entity} -> entity
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def delete_id(user, {resource_name, resource_maker}, id) do
    case Request.fetch(:delete, "#{API.endpoint(resource_name)}/#{id}", user) do
      {:ok, response} -> {:ok, process_single_response(response, resource_name, resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def delete_id!(user, {resource_name, resource_maker}, id) do
    case delete_id(user, {resource_name, resource_maker}, id) do
      {:ok, entity} -> entity
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def patch_id(user, {resource_name, resource_maker}, id) do
    case Request.fetch(:patch, "#{API.endpoint(resource_name)}/#{id}", user, payload: %{}) do
      {:ok, response} -> {:ok, process_single_response(response, resource_name, resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def patch_id!(user, {resource_name, resource_maker}, id) do
    case patch_id(user, {resource_name, resource_maker}, id) do
      {:ok, entity} -> entity
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  defp prepare_payload(resource_name, entities) do
    Map.put(
      %{},
      API.last_name_plural(resource_name),
      Enum.map(entities, &API.api_json/1)
    )
  end

  defp process_single_response(response, resource_name, resource_maker) do
    JSON.decode!(response)[API.last_name(resource_name)]
     |> API.from_api_json(resource_maker)
  end

  defp process_response(resource_name, resource_maker, response) do
    JSON.decode!(response)[API.last_name_plural(resource_name)]
     |> Enum.map(fn json -> API.from_api_json(json, resource_maker) end)
  end
end
