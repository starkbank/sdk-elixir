defmodule StarkBank.Boleto do

  @moduledoc """
  Groups Boleto related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Boleto.Data, as: Boleto
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Create Boletos

  Send a list of Boleto structs for creation in the Stark Bank API

  Parameters (required):
      boletos [list of Boleto structs]: list of Boleto structs to be created in the API
  Parameters (optional):
      user [Project entity, default nil]: Project struct returned from StarkBank.User.project().
  Return:
      list of Boleto structs with updated attributes
  """
  @spec create(Project.t(), [Boleto.t()]) ::
    {:ok, [Boleto.t()]} | {:error, [Error.t()]}
  def create(user, boletos) do
    Rest.post(
      user,
      resource(),
      boletos
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(Project.t(), [Boleto.t()]) :: any
  def create!(user, boletos) do
    Rest.post!(
      user,
      resource(),
      boletos
    )
  end

  @doc """
  Retrieve a specific Boleto

  Receive a single Boleto struct previously created in the Stark Bank API by passing its id

  Parameters (required):
      id [string]: struct unique id. ex: "5656565656565656"
  Parameters (optional):
      user [Project entity, default nil]: Project struct returned from StarkBank.User.project().
  Return:
      Boleto struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, Boleto.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: Boleto.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve a specific Boleto pdf file

  Receive a single Boleto pdf file generated in the Stark Bank API by passing its id

  Parameters (required):
      id [string]: struct unique id. ex: "5656565656565656"
  Parameters (optional):
      user [Project entity, default nil]: Project struct returned from StarkBank.User.project().
  Return:
      Boleto pdf file
  """
  @spec pdf(Project, binary) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(user, id) do
    Rest.get_pdf(user, resource(), id)
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(Project, binary) :: binary
  def pdf!(user, id) do
    Rest.get_pdf!(user, resource(), id)
  end

  @doc """
  Retrieve Boletos

  Receive a generator of Boleto structs previously created in the Stark Bank API

  Parameters (optional):
    limit [integer, default None]: maximum number of structs to be retrieved. Unlimited if None. ex: 35
    status [string, default None]: filter for status of retrieved structs. ex: "paid" or "registered"
    tags [list of strings, default None]: tags to filter retrieved structs. ex: ["tony", "stark"]
    ids [list of strings, default None]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    after [Date, default None] date filter for structs created only after specified date. ex: Date(2020, 3, 10)
    before [Date, default None] date filter for structs only before specified date. ex: Date(2020, 3, 10)
    user [Project struct, default None]: Project struct. Not necessary if starkbank.user was set before function call
  Return:
    stream of Boleto structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [Boleto.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil, created_after: nil, created_before: nil})
    Rest.get_list(user, resource(), limit, %{status: status, tags: tags, ids: ids, after: created_after, before: created_before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [Boleto.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids, created_after: created_after, created_before: created_before} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil, created_after: nil, created_before: nil})
    Rest.get_list!(user, resource(), limit, %{status: status, tags: tags, ids: ids, after: created_after, before: created_before})
  end

  @doc """
  Delete list of Boleto entities

  Delete a list of Boleto entities previously created in the Stark Bank API

  Parameters (required):
    id [string]: Boleto unique id. ex: "5656565656565656"
  Parameters (optional):
    user [Project entity, default nil]: Project struct returned from StarkBank.User.project().
  Return:
    list of deleted Boletos with updated attributes
  """
  @spec delete(Project, binary) :: {:ok, Boleto.t()} | {:error, [%Error{}]}
  def delete(user, id) do
    Rest.delete_id(user, resource(), id)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project, binary) :: Boleto.t()
  def delete!(user, id) do
    Rest.delete_id!(user, resource(), id)
  end

  defp resource() do
    %Boleto{amount: nil, name: nil, tax_id: nil, street_line_1: nil, street_line_2: nil, district: nil, city: nil, state_code: nil, zip_code: nil}
  end
end
