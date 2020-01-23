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

    {:ok, {{'HTTP/1.1', status_code, _status_message}, _headers, body}} =
      :httpc.request(
        method,
        get_request_params(credentials, url, body),
        [],
        []
      )

    {process_status_code(status_code), JSON.decode(body)}
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
          JSON.encode(body)
        }
    end
  end

  defp get_headers(credentials) do
    access_token = Auth.get_access_token(credentials)

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

  defp get_base_url(credentials) do
    env = Auth.get_env(credentials)

    cond do
      env == :sandbox -> 'https://sandbox.api.starkbank.com/v1/'
      env == :production -> 'https://api.starkbank.com/v1/'
    end
  end

  defp process_status_code(status_code) do
    cond do
      status_code == 200 -> :ok
      true -> :error
    end
  end
end
