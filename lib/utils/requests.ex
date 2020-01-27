defmodule StarkBank.Utils.Requests do
  alias StarkBank.Utils.JSON, as: JSON

  def get(credentials, endpoint, parameters \\ nil, decode_json \\ true) do
    send(credentials, endpoint, :get, nil, parameters, decode_json)
  end

  def post(credentials, endpoint, body \\ nil) do
    send(credentials, endpoint, :post, body, nil)
  end

  def put(credentials, endpoint, body \\ nil) do
    send(credentials, endpoint, :put, body, nil)
  end

  def delete(credentials, endpoint, parameters \\ nil) do
    send(credentials, endpoint, :delete, nil, parameters)
  end

  defp send(credentials, endpoint, method, body, parameters, decode_json \\ true) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    url = get_url(credentials, endpoint, parameters)

    {status_code, body} = make_http_request(method, credentials, url, body)

    if decode_json do
      {process_status_code(status_code), JSON.decode(body)}
    else
      {process_status_code(status_code), body}
    end
  end

  defp make_http_request(method, credentials, url, body, is_retry \\ false) do
    {:ok, {{'HTTP/1.1', status_code, _status_message}, _headers, response_body}} =
      :httpc.request(
        method,
        get_request_params(credentials, url, body),
        [],
        []
      )

    if authentication_error?(response_body) do
      if is_retry do
        {401, response_body}
      else
        StarkBank.Auth.update_access_token(credentials)
        make_http_request(method, credentials, url, body, true)
      end
    else
      {status_code, response_body}
    end
  end

  defp authentication_error?(body) do
    if String.contains?(to_string(body), "invalidAccessToken") do
      error = JSON.decode(body)["error"]

      cond do
        !is_map(error) -> false
        error["code"] == "invalidAccessToken" -> true
        true -> false
      end
    else
      false
    end
  end

  defp get_request_params(credentials, url, body) when is_nil(body) do
    {
      url,
      get_headers(credentials)
    }
  end

  defp get_request_params(credentials, url, body) do
    {
      url,
      get_headers(credentials),
      'text/plain',
      JSON.encode(body)
    }
  end

  defp get_headers(credentials) do
    access_token = StarkBank.Auth.get_access_token(credentials)

    cond do
      is_nil(access_token) ->
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

  defp get_url(credentials, endpoint, parameters) when is_nil(parameters) do
    get_base_url(credentials) ++ endpoint
  end

  defp get_url(credentials, endpoint, parameters) do
    list = for {k, v} <- parameters, !is_nil(v), do: "#{k}=#{v}"

    if length(list) > 0 do
      get_url(
        credentials,
        endpoint ++ to_charlist("?" <> String.replace(Enum.join(list, "&"), " ", "%20")),
        nil
      )
    else
      get_url(credentials, endpoint, nil)
    end
  end

  defp get_base_url(credentials) do
    env = StarkBank.Auth.get_env(credentials)

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
