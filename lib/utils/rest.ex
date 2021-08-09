defmodule StarkBank.Utils.Rest do
  @moduledoc false

  alias StarkBank.Utils.Request
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.QueryGenerator
  alias StarkBank.Utils.API
  alias StarkBank.Utils.JSON

  def get_page({resource_name, resource_maker}, options) do
    case Request.fetch(
      :get, 
      "#{API.endpoint(resource_name)}", 
      query: Enum.into(options, %{}) |> Map.delete(:user) |> API.cast_json_to_api_format(),
      user: options[:user]
    ) do
      {:ok, response} -> {:ok, process_page_response(resource_name, resource_maker, response)}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_page!({resource_name, resource_maker}, options) do
    case Request.fetch(
      :get, 
      "#{API.endpoint(resource_name)}", 
      query: Enum.into(options, %{}) |> Map.delete(:user) |> API.cast_json_to_api_format(), 
      user: options[:user]
    ) do
      {:ok, response} -> process_page_response(resource_name, resource_maker, response)
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def get_list({resource_name, resource_maker}, options) do
    {getter, query} = get_list_parameters(options, resource_name)

    Stream.resource(
      fn ->
        {:ok, pid} =
          QueryGenerator.start_query(
            getter,
            API.last_name_plural(resource_name),
            query
          )
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

  def get_list!({resource_name, resource_maker}, options) do
    {getter, query} = get_list_parameters(options, resource_name)

    Stream.resource(
      fn ->
        {:ok, pid} =
          QueryGenerator.start_query(
            getter,
            API.last_name_plural(resource_name),
            query
          )
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

  defp get_list_parameters(options, resource_name) do
    query = Enum.into(options |> Check.options(), %{})
    {
      make_getter(query[:user],resource_name),
      query |> Map.delete(:user) |> Map.put(:limit, query[:limit])
    }
  end

  defp make_getter(user, resource_name) do
    fn query ->
      Request.fetch(
        :get,
        API.endpoint(resource_name),
        query: query,
        user: user
      )
    end
  end

  def get_id({resource_name, resource_maker}, id, options) do
    user = options[:user]

    case Request.fetch(:get, "#{API.endpoint(resource_name)}/#{id}", user: user) do
      {:ok, response} -> {:ok, process_single_response(response, resource_name, resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_id!({resource_name, resource_maker}, id, options) do
    case get_id({resource_name, resource_maker}, id, options) do
      {:ok, entity} -> entity
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def get_content({resource_name, _resource_maker}, id, sub_resource_name, options, user) do
    case Request.fetch(:get, "#{API.endpoint(resource_name)}/#{id}/#{sub_resource_name}", query: options, user: user) do
      {:ok, content} -> {:ok, content}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_content!({resource_name, _resource_maker}, id, sub_resource_name, options, user) do
    case Request.fetch(:get, "#{API.endpoint(resource_name)}/#{id}/#{sub_resource_name}", query: options, user: user) do
      {:ok, content} -> content
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def post({resource_name, resource_maker}, entities, options) do
    user = options[:user]

    case Request.fetch(
      :post,
      "#{API.endpoint(resource_name)}",
      payload: prepare_payload(resource_name, entities),
      user: user
    ) do
      {:ok, response} -> {:ok, process_response(resource_name, resource_maker, response)}
      {:error, errors} -> {:error, errors}
    end
  end

  def post!({resource_name, resource_maker}, entities, options) do
    case post({resource_name, resource_maker}, entities, options) do
      {:ok, entities} -> entities
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def post_single({resource_name, resource_maker}, entity, options) do
    user = options[:user]

    case Request.fetch(
      :post,
      "#{API.endpoint(resource_name)}",
      payload: API.api_json(entity),
      user: user
    ) do
      {:ok, response} -> {:ok, process_single_response(response, resource_name, resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def post_single!({resource_name, resource_maker}, entity, options) do
    case post_single({resource_name, resource_maker}, entity, options) do
      {:ok, entity} -> entity
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def delete_id({resource_name, resource_maker}, id, options) do
    user = options[:user]

    case Request.fetch(:delete, "#{API.endpoint(resource_name)}/#{id}", user: user) do
      {:ok, response} -> {:ok, process_single_response(response, resource_name, resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def delete_id!({resource_name, resource_maker}, id, options) do
    case delete_id({resource_name, resource_maker}, id, options) do
      {:ok, entity} -> entity
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def patch_id({resource_name, resource_maker}, id, payload) do
    case Request.fetch(
      :patch,
      "#{API.endpoint(resource_name)}/#{id}",
      payload: payload |> Map.delete(:user) |> API.cast_json_to_api_format(),
      user: payload[:user]
    ) do
      {:ok, response} -> {:ok, process_single_response(response, resource_name, resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def patch_id!({resource_name, resource_maker}, id, payload) do
    case patch_id({resource_name, resource_maker}, id, payload) do
      {:ok, entity} -> entity
      {:error, errors} -> raise API.errors_to_string(errors)
    end
  end

  def get_sub_resource(resource_name, {sub_resource_name, sub_resource_maker}, id, options) do
    case Request.fetch(
      :get,
      "#{API.endpoint(resource_name)}/#{id}/#{API.endpoint(sub_resource_name)}",
      query: options |> Map.delete(:user) |> API.cast_json_to_api_format(),
      user: options[:user]
    ) do
      {:ok, response} -> {:ok, process_single_response(response, sub_resource_name, sub_resource_maker)}
      {:error, errors} -> {:error, errors}
    end
  end

  def get_sub_resource!(resource_name, {sub_resource_name, sub_resource_maker}, id, options) do
    case get_sub_resource(resource_name, {sub_resource_name, sub_resource_maker}, id, options) do
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

  defp process_page_response(resource_name, resource_maker, response) do
    decoded_response = JSON.decode!(response)
    {
      decoded_response["cursor"],
      decoded_response[API.last_name_plural(resource_name)]
        |> Enum.map(&(API.from_api_json(&1, resource_maker))) 
    }
  end
end
