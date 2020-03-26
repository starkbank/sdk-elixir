defmodule StarkBank.Payment.Boleto do

  @moduledoc """
  Groups BoletoPayment related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Payment.Boleto.Data, as: BoletoPaymentData
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  Create BoletoPayments

  Send a list of BoletoPayment structs for creation in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    payments [list of BoletoPayment structs]: list of BoletoPayment structs to be created in the API
  Return:
    list of BoletoPayment structs with updated attributes
  """
  @spec create(Project.t(), [BoletoPaymentData.t()]) ::
    {:ok, [BoletoPaymentData.t()]} | {:error, [Error.t()]}
  def create(user, payments) do
    Rest.post(
      user,
      resource(),
      payments
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(Project.t(), [BoletoPaymentData.t()]) :: any
  def create!(user, payments) do
    Rest.post!(
      user,
      resource(),
      payments
    )
  end

  @doc """
  Retrieve a specific BoletoPayment

  Receive a single BoletoPayment struct previously created by the Stark Bank API by passing its id

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    id [string]: struct unique id. ex: "5656565656565656"
  Return:
    BoletoPayment struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, BoletoPaymentData.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: BoletoPaymentData.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve a specific BoletoPayment pdf file

  Receive a single BoletoPayment pdf file generated in the Stark Bank API by passing its id

  Send a list of BoletoPayment structs for creation in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    id [string]: struct unique id. ex: "5656565656565656"
  Return:
    BoletoPayment pdf file
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
  Retrieve BoletoPayments

  Receive a stream of BoletoPayment structs previously created in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
  Parameters (optional):
    limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    status [string, default nil]: filter for status of retrieved structs. ex: "paid"
    tags [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
  Return:
    stream of BoletoPayment structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [BoletoPaymentData.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil})
    Rest.get_list(user, resource(), limit, %{status: status, tags: tags, ids: ids})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [BoletoPaymentData.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil})
    Rest.get_list!(user, resource(), limit, %{status: status, tags: tags, ids: ids})
  end

  @doc """
  Delete a BoletoPayment entity

  Delete a BoletoPayment entity previously created in the Stark Bank API

  Parameters (required):
    user [Project]: Project struct returned from StarkBank.User.project().
    id [string]: BoletoPayment unique id. ex: "5656565656565656"
  Return:
    deleted BoletoPayment with updated attributes
  """
  @spec delete(Project, binary) :: {:ok, BoletoPaymentData.t()} | {:error, [%Error{}]}
  def delete(user, id) do
    Rest.delete_id(user, resource(), id)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project, binary) :: BoletoPaymentData.t()
  def delete!(user, id) do
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
    %BoletoPaymentData{
      line: json[:line],
      bar_code: json[:bar_code],
      tax_id: json[:tax_id],
      description: json[:description],
      scheduled: json[:scheduled] |> Checks.check_datetime,
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      amount: json[:amount],
      created: json[:created] |> Checks.check_datetime
    }
  end
end
