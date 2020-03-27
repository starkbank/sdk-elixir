defmodule StarkBank.Utils.Checks do
  @moduledoc false

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
end
