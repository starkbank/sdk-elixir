defmodule StarkBankTest.Utils.Page do
  use ExUnit.Case

  def get!(function, iterations, options  \\ []) do
    get!(function, iterations, [], [], options)
  end

  defp get!(_function, iterations, ids, entities, _options) when iterations <= 0 and length(entities) == 0 do
    ids
  end

  defp get!(function, iterations, ids, entities, options) when length(entities) == 0 do
    {new_cursor, new_entities} = function.(options)
    get!(
      function,
      get_iterations(iterations, new_cursor),
      ids,
      new_entities,
      options
        |> Enum.into(%{})
        |> Map.put(:cursor, new_cursor)
        |> Map.to_list
    )
  end

  defp get!(function, iterations, ids, [entity | entities], options) do
    assert !Enum.member?(ids, entity.id)
    get!(function, iterations, [entity.id | ids], entities, options)
  end

  def get(function, iterations, options  \\ []) do
    get(function, iterations, [], [], options)
  end

  defp get(_function, iterations, ids, entities, _options) when iterations <= 0 and length(entities) == 0 do
    {:ok, ids}
  end

  defp get(function, iterations, ids, entities, options) when length(entities) == 0 do
    {:ok, {new_cursor, new_entities}} = function.(options)
    get(
      function,
      get_iterations(iterations, new_cursor),
      ids,
      new_entities,
      options
        |> Enum.into(%{})
        |> Map.put(:cursor, new_cursor)
        |> Map.to_list
    )
  end

  defp get(function, iterations, ids, [entity | entities], options) do
    assert !Enum.member?(ids, entity.id)
    get(function, iterations, [entity.id | ids], entities, options)
  end

  defp get_iterations(_iterations, cursor) when is_nil(cursor) do
    0
  end

  defp get_iterations(iterations, _cursor) do
    iterations - 1
  end
end
