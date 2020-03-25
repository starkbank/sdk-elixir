defmodule StarkBank.Utils.QueryGenerator do
  @moduledoc false

  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.JSON, as: JSON

  def start_query(function, limit, key) do
    Task.start_link(fn -> yield([], function, nil, limit, key) end)
  end

  def get(pid) do
    send(pid, self())
    receive do
      :halt -> :halt
      {:ok, element} -> {:ok, element}
      {:error, error} -> {:error, error}
    end
  end

  defp yield([head | tail], function, cursor, limit, key) do
    receive do
      caller ->
        send(caller, {:ok, head})
        yield(tail, function, cursor, limit, key)
    end
  end

  defp yield([], function, cursor, limit, key) when limit > 0 do
    case function.(cursor, Checks.check_limit(limit)) do
      {:ok, result} ->
        decoded = JSON.decode!(result)
        yield(
          decoded[key],
          function,
          decoded["cursor"],
          limit |> iterate_limit(),
          key
        )
      {:error, error} -> yield_error(error)
    end
  end

  defp yield([], _function, _cursor, _limit, _key) do
    receive do
      caller ->
        send(caller, :halt)
    end
  end

  defp yield_error(error) do
    receive do
      caller ->
        send(caller, {:error, error})
    end
  end

  defp iterate_limit(limit) when is_nil(limit) do
    nil
  end

  defp iterate_limit(limit) do
    limit - 100
  end
end
