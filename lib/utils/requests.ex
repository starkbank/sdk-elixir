defmodule Requests do
  def get(credentials, endpoint, parameters \\ nil) do
    send(credentials, endpoint, :get, nil, parameters)
  end

  def post(credentials, endpoint, body \\ nil) do
    send(credentials, endpoint, :post, body, nil)
  end

  def del(credentials, endpoint, parameters \\ nil) do
    send(credentials, endpoint, :delete, nil, parameters)
  end

  defp send(credentials, endpoint, method, body \\ nil, parameters \\ nil) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    url = get_url(credentials, endpoint, parameters)

    IO.puts(url)

    IO.puts("\nsending " <> to_string(method))
    IO.puts(inspect(get_request_params(credentials, url, body)))
    IO.puts(inspect(get_headers(credentials)))

    {:ok, {{'HTTP/1.1', status_code, _status_message}, _headers, body}} =
      :httpc.request(
        method,
        get_request_params(credentials, url, body),
        [],
        []
      )

    IO.puts("\nreceived")
    IO.puts(to_string(body))

    {process_status_code(status_code), JSON.decode(body)}
  end

  defp get_request_params(credentials, url, body) when body == nil do
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

  defp get_url(credentials, endpoint, parameters \\ nil) do
    url = get_base_url(credentials) ++ endpoint

    if parameters != nil do
      list = for {k, v} <- parameters, v != nil, do: "#{k}=#{v}"
      url ++ to_charlist("?" <> String.replace(Enum.join(list, "&"), " ", "%20"))
    else
      url
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
