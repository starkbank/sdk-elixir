defmodule Requests do
  def get(credentials, endpoint) do
    send(credentials, endpoint, :get)
  end

  def post(credentials, endpoint, body) do
    send(credentials, endpoint, :post, body)
  end

  defp send(credentials, endpoint, method, body \\ nil) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    url = get_base_url(credentials) ++ endpoint

    {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
      :httpc.request(
        method,
        get_request_params(credentials, url, body),
        [],
        []
      )
  end

  defp get_request_params(credentials, url, body) do
    {'http://httpbin.org/post', [], 'application/json', 'any body at all'}

    cond do
      body == nil ->
        {
          url,
          get_headers(credentials),
          'text/plain'
        }

      true ->
        {
          url,
          get_headers(credentials),
          'text/plain',
          map_to_json(body)
        }
    end
  end

  defp get_headers(credentials) do
    access_token = get_access_token(credentials)

    cond do
      access_token == nil ->
        [
          {'Content-Type', 'application/json'}
        ]

      true ->
        [
          {'Content-Type', 'application/json'},
          {'Access-Token', to_charlist(access_token)}
        ]
    end
  end

  defp map_to_json(map) do
    list = for {k, v} <- map, do: "\"#{k}\": \"#{v}\""
    to_charlist("{" <> Enum.join(list, ", ") <> "}")
  end

  defp get_base_url(credentials) do
    env = Agent.get(credentials, fn map -> Map.get(map, :env) end)

    cond do
      env == :sandbox -> 'https://sandbox.api.starkbank.com/v1/'
      env == :production -> 'https://api.starkbank.com/v1/'
    end
  end

  defp get_access_token(credentials) do
    Agent.get(credentials, fn map -> Map.get(map, :access_token) end)
  end
end
