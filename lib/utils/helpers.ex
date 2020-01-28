defmodule StarkBank.Utils.Helpers do
  @cursor_limit 100

  def list_to_url_arg(list) when is_nil(list) do
    nil
  end

  def list_to_url_arg(list) do
    Enum.join(list, ",")
  end

  def extract_id(id) when is_binary(id) or is_integer(id) or is_nil(id) do
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
    list_to_url_arg(for id_or_struct <- id_or_struct_list, do: extract_id(id_or_struct))
  end

  def nullable_fields_match?(nullable_field, _other_field) when is_nil(nullable_field) do
    true
  end

  def nullable_fields_match?(nullable_field, other_field) do
    nullable_field == other_field
  end

  def current_microsecond() do
    DateTime.utc_now()
    |> DateTime.to_unix(:microsecond)
  end

  def log_elapsed_time(since) do
    IO.puts("time elapsed: " <> to_string((current_microsecond() - since) / 1000_000))
  end

  def lowercase_list_of_strings(list_of_strings) when is_nil(list_of_strings) do
    nil
  end

  def lowercase_list_of_strings(list_of_strings) do
    for(string <- list_of_strings, do: String.downcase(string))
  end

  def snake_to_camel_list_of_strings(list_of_strings) when is_nil(list_of_strings) do
    nil
  end

  def snake_to_camel_list_of_strings(list_of_strings) do
    for string <- list_of_strings, do: Enum.join(snake_to_camel(String.graphemes(string)))
  end

  defp snake_to_camel([letter | rest]) when letter == "_" do
    snake_to_camel([String.upcase(hd(rest)) | tl(rest)])
  end

  defp snake_to_camel([letter | rest]) do
    [letter | snake_to_camel(rest)]
  end

  defp snake_to_camel([]) do
    []
  end
end
