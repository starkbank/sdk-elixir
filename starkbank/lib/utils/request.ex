defmodule StarkBank.Utils.Request do
  @moduledoc false

  alias StarkBank.Utils.JSON, as: JSON

  def fetch(method, path, user, options \\ []) do
    %{payload: payload, query: query, version: version} =
      Enum.into(options, %{payload: nil, query: nil, version: 'v2'})

    url = get_url(user.environment, version, path, query)

    {status_code, response_body} = request(method, user, url, payload)

    process_response(status_code, response_body)
  end

  defp request(method, user, url, payload) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    {:ok, {{'HTTP/1.1', status_code, _status_message}, _headers, response_body}} =
      :httpc.request(
        method,
        get_request_params(user, url, JSON.encode!(payload)),
        [],
        []
      )

    {status_code, response_body}
  end

  defp get_request_params(user, url, body) when is_nil(body) do
    {
      url,
      get_headers(user, "")
    }
  end

  defp get_request_params(user, url, body) do
    {
      url,
      get_headers(user, body),
      'text/plain',
      body
    }
  end

  defp get_headers(user, body) do
    access_time = DateTime.utc_now() |> DateTime.to_unix(:second)
    signature = "#{user.access_id}:#{access_time}:#{body}"
     |> EllipticCurve.Ecdsa.sign(user.private_key)
     |> EllipticCurve.Signature.toBase64()

    [
      {'Access-Id', to_charlist(user.access_id)},
      {'Access-Time', to_charlist(access_time)},
      {'Access-Signature', to_charlist(signature)},
      {'Content-Type', 'application/json'},
      {'User-Agent', 'Elixir-#{System.version}-SDK-#{Mix.Project.config[:version]}'}
    ]
  end

  defp get_url(environment, version, path, query) do
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

  defp add_query(endpoint, query) do
    list = for {k, v} <- query, !is_nil(v), do: "#{k}=#{v}"

    if length(list) > 0 do
      endpoint ++ to_charlist("?" <> String.replace(Enum.join(list, "&"), " ", "%20"))
    else
      endpoint
    end
  end

  defp process_response(status_code, body) do
    cond do
      status_code == 500 -> {:internal_error, ["Houston, we have a problem."]}
      status_code == 400 -> {:error, JSON.decode!(body)["errors"]}
      status_code != 200 -> {:unknown_error, ["Unknown exception encountered: " <> to_string(body)]}
      true -> {:ok, body}
    end
  end
end
