defmodule StarkBank.Boleto.Log do

  @moduledoc """
  Groups BoletoLog related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.Utils.API, as: API
  alias StarkBank.Boleto.Log.Data, as: BoletoLogData
  alias StarkBank.Boleto, as: Boleto
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  # Retrieve a specific BoletoLog

  Receive a single BoletoLog struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - BoletoLog struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, BoletoLogData.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: BoletoLogData.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  Retrieve BoletoLogs

  Receive a stream of BoletoLog structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - boleto_ids [list of strings, default nil]: list of Boleto ids to filter logs. ex: ["5656565656565656", "4545454545454545"]
    - types [list of strings, default nil]: filter for log event types. ex: "paid" or "registered"
    - after_ [Date, default nil] date filter for structs created only after specified date. ex: Date(2020, 3, 10)
    - before [Date, default nil] date filter for structs only before specified date. ex: Date(2020, 3, 10)

  ## Return:
    - stream of BoletoLog structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [BoletoLogData.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit, boleto_ids: boleto_ids, types: types, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, boleto_ids: nil, types: nil, after_: nil, before: nil})
    Rest.get_list(user, resource(), limit, %{boleto_ids: boleto_ids, types: types, after: after_, before: before})
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [BoletoLogData.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit, boleto_ids: boleto_ids, types: types, after_: after_, before: before} =
      Enum.into(options, %{limit: nil, boleto_ids: nil, types: nil, after_: nil, before: nil})
    Rest.get_list!(user, resource(), limit, %{boleto_ids: boleto_ids, types: types, after: after_, before: before})
  end

  @doc false
  def resource() do
    {
      "BoletoLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BoletoLogData{
      id: json[:id],
      boleto: json[:boleto] |> API.from_api_json(&Boleto.resource_maker/1),
      created: json[:created] |> Checks.check_datetime,
      type: json[:type],
      errors: json[:errors]
    }
  end
end
