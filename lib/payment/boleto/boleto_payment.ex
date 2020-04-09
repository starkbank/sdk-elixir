defmodule StarkBank.BoletoPayment do

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.BoletoPayment, as: BoletoPayment
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @moduledoc """
  Groups BoletoPayment related functions

  # BoletoPayment struct:

  When you initialize a BoletoPayment, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (conditionally required):
    - line [string, default nil]: Number sequence that describes the payment. Either 'line' or 'bar_code' parameters are required. If both are sent, they must match. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    - bar_code [string, default nil]: Bar code number that describes the payment. Either 'line' or 'barCode' parameters are required. If both are sent, they must match. ex: "34195819600000000621090063571277307144464000"

  ## Parameters (required):
    - tax_id [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - description [string]: Text to be displayed in your statement (min. 10 characters). ex: "payment ABC"

  ## Parameters (optional):
    - scheduled [Date, default today]: payment scheduled date. ex: ~D[2020-03-25]
    - tags [list of strings]: list of strings for tagging

  ## Attributes (return-only):
    - id [string, default nil]: unique id returned when payment is created. ex: "5656565656565656"
    - status [string, default nil]: current payment status. ex: "registered" or "paid"
    - amount [int, default nil]: amount automatically calculated from line or bar_code. ex: 23456 (= R$ 234.56)
    - fee [integer, default nil]: fee charged when a boleto payment is created. ex: 200 (= R$ 2.00)
    - created [DateTime, default nil]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:tax_id, :description]
  defstruct [:line, :bar_code, :tax_id, :description, :scheduled, :tags, :id, :status, :amount, :fee, :created]

  @type t() :: %__MODULE__{}

  @doc """
  # Create BoletoPayments

  Send a list of BoletoPayment structs for creation in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - payments [list of BoletoPayment structs]: list of BoletoPayment structs to be created in the API

  ## Return:
    - list of BoletoPayment structs with updated attributes
  """
  @spec create(Project.t(), [BoletoPayment.t()]) ::
    {:ok, [BoletoPayment.t()]} | {:error, [Error.t()]}
  def create(%Project{} = user, payments) do
    Rest.post(
      user,
      resource(),
      payments
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(Project.t(), [BoletoPayment.t()]) :: any
  def create!(%Project{} = user, payments) do
    Rest.post!(
      user,
      resource(),
      payments
    )
  end

  @doc """
  # Retrieve a specific BoletoPayment

  Receive a single BoletoPayment struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - BoletoPayment struct with updated attributes
  """
  @spec get(Project.t(), binary) :: {:ok, BoletoPayment.t()} | {:error, [%Error{}]}
  def get(%Project{} = user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project.t(), binary) :: BoletoPayment.t()
  def get!(%Project{} = user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  # Retrieve a specific BoletoPayment pdf file

  Receive a single BoletoPayment pdf file generated in the Stark Bank API by passing its id.
  Only valid for boleto payments with "success" status.

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - BoletoPayment pdf file content
  """
  @spec pdf(Project.t(), binary) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(%Project{} = user, id) do
    Rest.get_pdf(user, resource(), id)
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(Project.t(), binary) :: binary
  def pdf!(%Project{} = user, id) do
    Rest.get_pdf!(user, resource(), id)
  end

  @doc """
  # Retrieve BoletoPayments

  Receive a stream of BoletoPayment structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - status [string, default nil]: filter for status of retrieved structs. ex: "paid"
    - tags [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]

  ## Return:
    - stream of BoletoPayment structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [BoletoPayment.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(%Project{} = user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil, after_: nil, before: nil})
    Rest.get_list(user, resource(), limit, %{status: status, tags: tags, ids: ids, after: after_ |> Checks.check_date, before: before |> Checks.check_date})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [BoletoPayment.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(%Project{} = user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil, after_: nil, before: nil})
    Rest.get_list!(user, resource(), limit, %{status: status, tags: tags, ids: ids, after: after_ |> Checks.check_date, before: before |> Checks.check_date})
  end

  @doc """
  # Delete a BoletoPayment entity

  Delete a BoletoPayment entity previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: BoletoPayment unique id. ex: "5656565656565656"

  ## Return:
    - deleted BoletoPayment struct with updated attributes
  """
  @spec delete(Project.t(), binary) :: {:ok, BoletoPayment.t()} | {:error, [%Error{}]}
  def delete(%Project{} = user, id) do
    Rest.delete_id(user, resource(), id)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project.t(), binary) :: BoletoPayment.t()
  def delete!(%Project{} = user, id) do
    Rest.delete_id!(user, resource(), id)
  end

  @doc false
  def resource() do
    {
      "BoletoPayment",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BoletoPayment{
      line: json[:line],
      bar_code: json[:bar_code],
      tax_id: json[:tax_id],
      description: json[:description],
      scheduled: json[:scheduled] |> Checks.check_datetime,
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      amount: json[:amount],
      fee: json[:fee],
      created: json[:created] |> Checks.check_datetime
    }
  end
end
