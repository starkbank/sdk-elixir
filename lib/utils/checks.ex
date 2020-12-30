defmodule StarkBank.Utils.Check do
  @moduledoc false

  alias EllipticCurve.PrivateKey
  alias StarkBank.User.Project
  alias StarkBank.User.Organization

  def environment(environment) do
    case environment do
      :production -> environment
      :sandbox -> environment
      nil -> raise "please set an environment"
      _any -> raise "environment must be either :production or :sandbox"
    end
  end

  def limit(limit) when is_nil(limit) do
    nil
  end

  def limit(limit) do
    min(limit, 100)
  end

  def datetime(data) when is_nil(data) do
    nil
  end

  def datetime(data) when is_binary(data) do
    {:ok, datetime, _utc_offset} = data |> DateTime.from_iso8601()
    datetime
  end

  def date(data) when is_nil(data) do
    nil
  end

  def date(data) when is_binary(data) do
    data |> Date.from_iso8601!()
  end

  def date(data = %DateTime{}) do
    %Date{year: data.year, month: data.month, day: data.day}
  end

  def date(data) do
    data
  end

  def private_key(private_key) do
    try do
      {:ok, parsed_key} = PrivateKey.fromPem(private_key)
      :secp256k1 = parsed_key.curve.name
      parsed_key
    rescue
      _e -> raise "private_key must be valid secp256k1 ECDSA string in pem format"
    else
      parsed_key -> parsed_key
    end
  end

  def options(options) do
    options
    |> Enum.into(%{})
    |> fill_limit()
    |> fill_date_field(:after)
    |> fill_date_field(:before)
  end

  defp fill_limit(options) do
    if !Map.has_key?(options, :limit) do
      Map.put(options, :limit, nil)
    end
    options
  end

  defp fill_date_field(options, field) do
    if !Map.has_key?(options, field) do
      Map.put(options, field, nil)
    else
      Map.update!(options, field, &date/1)
    end
  end

  def user(user) when is_nil(user) do
    case Application.fetch_env(:starkbank, :project) do
      {:ok, project_info} -> project_info |> StarkBank.project()
      :error -> raise "no default user was located in configs and no user was passed in the request"
    end
  end

  def user(user = %Project{}) do
    user
  end

  def language() do
    case Application.fetch_env(:starkbank, :language) do
      {:ok, 'en-US'} -> 'en-US'
      {:ok, "en-US"} -> 'en-US'
      {:ok, 'pt-BR'} -> 'pt-BR'
      {:ok, "pt-BR"} -> 'pt-BR'
      :error -> 'en-US'
    end
  end

  def enforced_keys(parameters, enforced_keys) do
    case get_missing_keys(parameters |> Enum.into(%{}), enforced_keys) do
      [] -> parameters
      missing_keys -> raise "the following parameters are missing: " <> Enum.join(missing_keys, ", ")
    end
  end

  def get_missing_keys(parameters, [key | other_enforced_keys]) do
    missing_keys = get_missing_keys(parameters, other_enforced_keys)
    case Map.has_key?(parameters, key) do
      true -> missing_keys
      false -> [key | missing_keys]
    end
  end

  def get_missing_keys(_parameters, []) do
    []
  end
end
