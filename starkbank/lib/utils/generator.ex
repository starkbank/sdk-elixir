defmodule StarkBank.Utils.QueryGenerator do
  @moduledoc false

  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.JSON, as: JSON

  def start_query(function, key, query) do
    Task.start_link(fn -> yield([], function, key, query) end)
  end

  def get(pid) do
    send(pid, self())
    receive do
      :halt -> :halt
      {:ok, element} -> {:ok, element}
      {:error, errors} -> {:error, errors}
    end
  end

  defp yield([head | tail], function, key, query) do
    receive do
      caller ->
        send(caller, {:ok, head})
        yield(tail, function, key, query)
    end
  end

  defp yield([], function, key, query) do
    limit = query[:limit]
    if is_nil(limit) or limit > 0 do
      case function.(query |> Map.put(:limit, limit |> Checks.check_limit)) do
        {:ok, result} ->
          decoded = JSON.decode!(result)
          yield(
            decoded[key],
            function,
            key,
            query |> Map.put(:cursor, decoded["cursor"]) |> Map.put(:limit, iterate_limit(limit))
          )
        {:error, error} -> yield_error(error)
      end
    else
      receive do
        caller ->
          send(caller, :halt)
      end
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
