defmodule StarkBank.Payment.Utility do

  @moduledoc """
  Groups UtilityPayment related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Payment.Utility.Data, as: UtilityPaymentData
  alias StarkBank.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  # Create UtilityPayments

  Send a list of UtilityPayment structs for creation in the Stark Bank API

  ## Parameters (required):
    - user [Project struct]: Project struct. Not necessary if starkbank.user was set before function call
    - payments [list of UtilityPayment structs]: list of UtilityPayment structs to be created in the API

  ## Return:
    - list of UtilityPayment structs with updated attributes
  """
  @spec create(Project.t(), [UtilityPaymentData.t()]) ::
    {:ok, [UtilityPaymentData.t()]} | {:error, [Error.t()]}
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
  @spec create!(Project.t(), [UtilityPaymentData.t()]) :: any
  def create!(user, payments) do
    Rest.post!(
      user,
      resource(),
      payments
    )
  end

  @doc """
  # Retrieve a specific UtilityPayment

  Receive a single UtilityPayment struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project struct]: Project struct. Not necessary if starkbank.user was set before function call
    - id [string]: struct unique id. ex: "5656565656565656"
  """
  @spec get(Project, binary) :: {:ok, UtilityPaymentData.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: UtilityPaymentData.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  # Retrieve a specific UtilityPayment pdf file

  Receive a single UtilityPayment pdf file generated in the Stark Bank API by passing its id.
  Only valid for utility payments with "success" status.

  ## Parameters (required):
    - user [Project struct]: Project struct. Not necessary if starkbank.user was set before function call
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - UtilityPayment pdf file content
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
  # Retrieve UtilityPayments

  Receive a stream of UtilityPayment structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.User.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - status [string, default nil]: filter for status of retrieved structs. ex: "paid"
    - tags [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - ids [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]

  ## Return:
    - stream of UtilityPayment structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [UtilityPaymentData.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil})
    Rest.get_list(user, resource(), limit, %{status: status, tags: tags, ids: ids})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [UtilityPaymentData.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil})
    Rest.get_list!(user, resource(), limit, %{status: status, tags: tags, ids: ids})
  end

  @doc """
  # Delete a UtilityPayment entity

  Delete a UtilityPayment entity previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.User.project().
    - id [string]: UtilityPayment unique id. ex: "5656565656565656"

  ## Return:
    - deleted UtilityPayment with updated attributes
  """
  @spec delete(Project, binary) :: {:ok, UtilityPaymentData.t()} | {:error, [%Error{}]}
  def delete(user, id) do
    Rest.delete_id(user, resource(), id)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project, binary) :: UtilityPaymentData.t()
  def delete!(user, id) do
    Rest.delete_id!(user, resource(), id)
  end

  @doc false
  def resource() do
    {
      "UtilityPayment",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %UtilityPaymentData{
      line: json[:line],
      bar_code: json[:bar_code],
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
