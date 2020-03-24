defmodule StarkBank.Utils.Rest do
  @moduledoc false

  alias StarkBank.Utils.Request, as: Request
  alias StarkBank.Utils.QueryGenerator, as: QueryGenerator
  alias StarkBank.Utils.Checks, as: Checks

  def get_list(user, resource, limit \\ 100, query \\ %{}) do
    query_params = query |> Map.put(:limit, limit) |> Map.put(:cursor, nil)

    getter = fn cursor, limit -> Request.fetch(
        :get,
        resource,
        user,
        query:
        query_params |> Map.put(:cursor, cursor) |> Map.put(:limit, limit)
      ) end

    Stream.resource(
      fn ->
        {:ok, pid} = QueryGenerator.start_link(getter, limit)
        pid
      end,
      fn pid ->
        case send(pid, self()) do
          :end -> {:halt, pid}
          {:ok, element} -> {[{:ok, element}], pid}
          {error_kind, error} -> {[{error_kind, error}], pid}
        end
      end,
      fn _pid -> nil end
    )
  end
end
