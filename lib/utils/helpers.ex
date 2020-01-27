defmodule StarkBank.Utils.Helpers do
  @cursor_limit 100

  def treat_list(list) when list == nil do
    nil
  end

  def treat_list(list) do
    Enum.join(list, ",")
  end

  def extract_id(id) when is_binary(id) or is_integer(id) do
    id
  end

  def extract_id(struct) do
    struct.id
  end

  def date_to_string(date) when is_nil(date) do
    nil
  end

  def date_to_string(date) when is_binary(date) do
    date
  end

  def date_to_string(date) do
    "#{date.year}-#{date.month}-#{date.day}"
  end

  def get_recursive_limit(limit) when is_nil(limit) do
    nil
  end

  def get_recursive_limit(limit) do
    limit - @cursor_limit
  end

  def truncate_limit(limit) when is_nil(limit) or limit > @cursor_limit do
    @cursor_limit
  end

  def truncate_limit(limit) do
    limit
  end

  def limit_below_maximum?(limit) do
    !is_nil(limit) and limit <= @cursor_limit
  end

  def chunk_list_by_max_limit(list) do
    Stream.chunk_every(list, @cursor_limit)
  end

  def flatten_responses(response_list) do
    errors = List.flatten(for {:error, response} <- response_list, do: response)

    if length(errors) > 0 do
      {:error, errors}
    else
      {:ok, List.flatten(for {:ok, response} <- response_list, do: response)}
    end
  end

  def treat_nullable_id_or_struct_list(id_or_struct_list) when is_nil(id_or_struct_list) do
    nil
  end

  def treat_nullable_id_or_struct_list(id_or_struct_list) do
    treat_list(for id_or_struct <- id_or_struct_list, do: extract_id(id_or_struct))
  end
end
