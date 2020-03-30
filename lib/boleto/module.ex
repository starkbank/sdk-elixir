defmodule StarkBank.Boleto do

  @moduledoc """
  Groups Boleto related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Boleto.Data, as: BoletoData
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  # Create Boletos

  Send a list of Boleto structs for creation in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - boletos [list of Boleto structs]: list of Boleto structs to be created in the API

  ## Return:
    - list of Boleto structs with updated attributes
  """
  @spec create(Project.t(), [BoletoData.t()]) ::
    {:ok, [BoletoData.t()]} | {:error, [Error.t()]}
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
  @spec create!(Project.t(), [BoletoData.t()]) :: any
  def create!(user, boletos) do
    Rest.post!(
      user,
      resource(),
      boletos
    )
  end

  @doc """
  # Retrieve a specific Boleto

  Receive a single Boleto struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - Boleto struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, BoletoData.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: BoletoData.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  # Retrieve a specific Boleto pdf file

  Receive a single Boleto pdf file generated in the Stark Bank API by passing its id.

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - Boleto pdf file content
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
  # Retrieve Boletos

  Receive a stream of Boleto structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - status [string, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
    - tags [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - ids [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - after_ [Date, default nil] date filter for structs created only after specified date. ex: Date(2020, 3, 10)
    - before [Date, default nil] date filter for structs only before specified date. ex: Date(2020, 3, 10)

  ## Return:
    - stream of Boleto structs with updated attributes
  """
  @spec query(Project.t(), any) ::
        ({:cont, {:ok, [BoletoData.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil, after_: nil, before: nil})
    Rest.get_list(user, resource(), limit, %{status: status, tags: tags, ids: ids, after: after_, before: before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [BoletoData.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil, after_: nil, before: nil})
    Rest.get_list!(user, resource(), limit, %{status: status, tags: tags, ids: ids, after: after_, before: before})
  end

  @doc """
  # Delete list of Boleto entities

  Delete a list of Boleto entities previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: Boleto unique id. ex: "5656565656565656"

  ##  Return:
    - deleted Boleto struct with updated attributes
  """
  @spec delete(Project, binary) :: {:ok, BoletoData.t()} | {:error, [%Error{}]}
  def delete(user, id) do
    Rest.delete_id(user, resource(), id)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project, binary) :: BoletoData.t()
  def delete!(user, id) do
    Rest.delete_id!(user, resource(), id)
  end

  @doc false
  def resource() do
    {
      "Boleto",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BoletoData{
      amount: json[:amount],
      name: json[:name],
      tax_id: json[:tax_id],
      street_line_1: json[:street_line_1],
      street_line_2: json[:street_line_2],
      district: json[:district],
      city: json[:city],
      state_code: json[:state_code],
      zip_code: json[:zip_code],
      due: json[:due] |> Checks.check_datetime,
      fine: json[:fine],
      interest: json[:interest],
      overdue_limit: json[:overdue_limit],
      tags: json[:tags],
      descriptions: json[:descriptions],
      id: json[:id],
      fee: json[:fee],
      line: json[:line],
      bar_code: json[:bar_code],
      status: json[:status],
      created: json[:created] |> Checks.check_datetime
    }
  end
end
