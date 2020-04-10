defmodule StarkBank.Utils.Checks do
  @moduledoc false

  alias EllipticCurve.PrivateKey, as: PrivateKey

  def check_environment(environment) do
    case environment do
      :production -> environment
      :sandbox -> environment
    end
  end

  def check_limit(limit) when is_nil(limit) do
    nil
  end

  def check_limit(limit) do
    min(limit, 100)
  end

  def check_datetime(data) when is_nil(data) do
    nil
  end

  def check_datetime(data) when is_binary(data) do
    {:ok, datetime, _utc_offset} = data |> DateTime.from_iso8601
    datetime
  end

  def check_date(data) when is_nil(data) do
    nil
  end

  def check_date(data) when is_binary(data) do
    data |> Date.from_iso8601!
  end

  def check_date(data = %DateTime{}) do
    %Date{year: data.year, month: data.month, day: data.day}
  end

  def check_date(data) do
    data
  end

  def check_private_key(private_key) do
    try do
      {:ok, parsed_key} = PrivateKey.fromPem(private_key)
      :secp256k1 = parsed_key.curve.name
      parsed_key
    rescue
      _e -> raise "Private-key must be valid secp256k1 ECDSA string in pem format"
    else
      parsed_key -> parsed_key
    end
  end

  def check_options(options, after_before) when after_before do
    options
     |> Enum.into(%{})
     |> fill_limit
     |> fill_date_field(:after)
     |> fill_date_field(:before)
  end

  def check_options(options) do
    options
     |> Enum.into(%{})
     |> fill_limit
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
      Map.update!(options, field, &check_date/1)
    end
  end
end
