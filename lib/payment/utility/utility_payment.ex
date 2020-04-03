defmodule StarkBank.Payment.Utility do

  alias __MODULE__, as: UtilityPayment
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @moduledoc """
  Groups UtilityPayment related functions

  # UtilityPayment struct:

  When you initialize a UtilityPayment, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (conditionally required):
    - line [string, default nil]: Number sequence that describes the payment. Either 'line' or 'bar_code' parameters are required. If both are sent, they must match. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    - bar_code [string, default nil]: Bar code number that describes the payment. Either 'line' or 'barCode' parameters are required. If both are sent, they must match. ex: "34195819600000000621090063571277307144464000"

  ## Parameters (required):
    - description [string]: Text to be displayed in your statement (min. 10 characters). ex: "payment ABC"

  ## Parameters (optional):
    - scheduled [Date, default today]: payment scheduled date. ex: ~D[2020-03-25]
    - tags [list of strings]: list of strings for tagging

  Attributes (return-only):
    - id [string, default nil]: unique id returned when payment is created. ex: "5656565656565656"
    - status [string, default nil]: current payment status. ex: "registered" or "paid"
    - amount [int, default nil]: amount automatically calculated from line or bar_code. ex: 23456 (= R$ 234.56)
    - fee [integer, default nil]: fee charged when a utility payment is created. ex: 200 (= R$ 2.00)
    - created [DateTime, default nil]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:description]
  defstruct [:line, :bar_code, :description, :scheduled, :tags, :id, :status, :amount, :fee, :created]

  @doc """
  # Create UtilityPayments

  Send a list of UtilityPayment structs for creation in the Stark Bank API

  ## Parameters (required):
    - user [Project struct]: Project struct. Not necessary if starkbank.user was set before function call
    - payments [list of UtilityPayment structs]: list of UtilityPayment structs to be created in the API

  ## Return:
    - list of UtilityPayment structs with updated attributes
  """
  @spec create(Project.t(), [UtilityPayment.t()]) ::
    {:ok, [UtilityPayment.t()]} | {:error, [Error.t()]}
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
  @spec create!(Project.t(), [UtilityPayment.t()]) :: any
  def create!(%Project{} = user, payments) do
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
  @spec get(Project.t(), binary) :: {:ok, UtilityPayment.t()} | {:error, [%Error{}]}
  def get(%Project{} = user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project.t(), binary) :: UtilityPayment.t()
  def get!(%Project{} = user, id) do
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
  # Retrieve UtilityPayments

  Receive a stream of UtilityPayment structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - status [string, default nil]: filter for status of retrieved structs. ex: "paid"
    - tags [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - ids [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]

  ## Return:
    - stream of UtilityPayment structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [UtilityPayment.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(%Project{} = user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil, after_: nil, before: nil})
    Rest.get_list(user, resource(), limit, %{status: status, tags: tags, ids: ids, after: after_, before: before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [UtilityPayment.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(%Project{} = user, options \\ []) do
    %{limit: limit, status: status, tags: tags, ids: ids, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, status: nil, tags: nil, ids: nil, after_: nil, before: nil})
    Rest.get_list!(user, resource(), limit, %{status: status, tags: tags, ids: ids, after: after_, before: before})
  end

  @doc """
  # Delete a UtilityPayment entity

  Delete a UtilityPayment entity previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: UtilityPayment unique id. ex: "5656565656565656"

  ## Return:
    - deleted UtilityPayment with updated attributes
  """
  @spec delete(Project.t(), binary) :: {:ok, UtilityPayment.t()} | {:error, [%Error{}]}
  def delete(%Project{} = user, id) do
    Rest.delete_id(user, resource(), id)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project.t(), binary) :: UtilityPayment.t()
  def delete!(%Project{} = user, id) do
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
    %UtilityPayment{
      line: json[:line],
      bar_code: json[:bar_code],
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
