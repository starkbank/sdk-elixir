defmodule StarkBank.Payment.Utility.Log do

  alias __MODULE__, as: UtilityPaymentLog
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Payment.Utility, as: UtilityPayment
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @moduledoc """
  Groups UtilityPaymentLog related functions

  # UtilityPaymentLog struct:

  Every time a UtilityPayment entity is modified, a corresponding UtilityPaymentLog
  is generated for the entity. This log is never generated by the user, but it can
  be retrieved to check additional information on the UtilityPayment.

  ## Attributes:
    - id [string]: unique id returned when the log is created. ex: "5656565656565656"
    - payment [UtilityPayment]: UtilityPayment entity to which the log refers to.
    - errors [list of strings]: list of errors linked to this BoletoPayment event.
    - type [string]: type of the UtilityPayment event which triggered the log creation. ex: "registered" or "paid"
    - created [DateTime]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :payment, :errors, :type, :created]
  defstruct [:id, :payment, :errors, :type, :created]

  @type t() :: %__MODULE__{}

  @doc """
  # Retrieve a specific UtilityPaymentLog

  Receive a single UtilityPaymentLog struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - UtilityPaymentLog struct with updated attributes
  """
  @spec get(Project.t(), binary) :: {:ok, UtilityPaymentLog.t()} | {:error, [%Error{}]}
  def get(%Project{} = user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project.t(), binary) :: UtilityPaymentLog.t()
  def get!(%Project{} = user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  # Retrieve UtilityPaymentLogs

  Receive a stream of UtilityPaymentLog structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - payment_ids [list of strings, default nil]: list of UtilityPayment ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - types [list of strings, default nil]: filter retrieved structs by event types. ex: "paid" or "registered"

  ## Return:
    - stream of UtilityPaymentLog structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [UtilityPaymentLog.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(%Project{} = user, options \\ []) do
    %{limit: limit, payment_ids: payment_ids, types: types} =
      Enum.into(options, %{limit: nil, payment_ids: nil, types: nil})
    Rest.get_list(user, resource(), limit, %{payment_ids: payment_ids, types: types})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [UtilityPaymentLog.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(%Project{} = user, options \\ []) do
    %{limit: limit, payment_ids: payment_ids, types: types} =
      Enum.into(options, %{limit: nil, payment_ids: nil, types: nil})
    Rest.get_list!(user, resource(), limit, %{payment_ids: payment_ids, types: types})
  end

  @doc false
  def resource() do
    {
      "UtilityPaymentLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %UtilityPaymentLog{
      id: json[:id],
      payment: json[:payment] |> API.from_api_json(&UtilityPayment.resource_maker/1),
      created: json[:created] |> Checks.check_datetime,
      type: json[:type],
      errors: json[:errors]
    }
  end
end
