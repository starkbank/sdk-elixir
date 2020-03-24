defmodule StarkBank.Utils.QueryGenerator do
  @moduledoc false

  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.JSON, as: JSON

  def start_link(function, limit) do
    Task.start_link(fn -> yield([], function, nil, limit) end)
  end

  defp yield([head | tail], function, cursor, limit) do
    receive do
      caller ->
        send caller, {:ok, head}
        yield(tail, function, cursor, limit)
    end
  end

  defp yield([], function, cursor, limit) when limit > 0 do
    case function.(cursor, Checks.check_limit(limit)) do
      {:ok, result, cursor} -> yield(
        JSON.decode!(result),
        function,
        cursor,
        limit |> iterate_limit()
      )
      {error_kind, error} -> yield_error(error_kind, error)
    end
  end

  defp yield([], _function, _cursor, _limit) do
    receive do
      caller ->
        send caller, :end
    end
  end

  defp yield_error(error_kind, error) do
    receive do
      caller ->
        send caller, {error_kind, error}
    end
  end

  defp iterate_limit(limit) when is_nil(limit) do
    nil
  end

  defp iterate_limit(limit) do
    limit - 100
  end
end
