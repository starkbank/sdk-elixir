defmodule StarkBank.IssPayment do
  alias __MODULE__, as: IssPayment
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups IssPayment related functions
  """

  @doc """
  When you initialize a IssPayment, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (conditionally required):
    - `:line` [string, default nil]: Number sequence that describes the payment. Either 'line' or 'bar_code' parameters are required. If both are sent, they must match. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    - `:bar_code` [string, default nil]: Bar code number that describes the payment. Either 'line' or 'barCode' parameters are required. If both are sent, they must match. ex: "34195819600000000621090063571277307144464000"

  ## Parameters (required):
    - `:description` [string]: Text to be displayed in your statement (min. 10 characters). ex: "payment ABC"

  ## Parameters (optional):
    - `:scheduled` [Date, DateTime or string, default today]: payment scheduled date. ex: ~D[2020-03-25]
    - `:tags` [list of strings]: list of strings for tagging

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when payment is created. ex: "5656565656565656"
    - `:status` [string, default nil]: current payment status. ex: "success" or "failed"
    - `:amount` [int, default nil]: amount automatically calculated from line or bar_code. ex: 23456 (= R$ 234.56)
    - `:fee` [integer, default nil]: fee charged when a ISS payment is created. ex: 200 (= R$ 2.00)
    - `:created` [DateTime, default nil]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:description]
  defstruct [
    :line,
    :bar_code,
    :description,
    :scheduled,
    :tags,
    :id,
    :status,
    :amount,
    :fee,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of IssPayment structs for creation in the Stark Bank API

  ## Parameters (required):
    - `payments` [list of IssPayment structs]: list of IssPayment structs to be created in the API

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - list of IssPayment structs with updated attributes
  """
  @spec create([IssPayment.t() | map()], user: Project.t() | nil) ::
          {:ok, [IssPayment.t()]} | {:error, [Error.t()]}
  def create(payments, options \\ []) do
    Rest.post(
      resource(),
      payments,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([IssPayment.t() | map()], user: Project.t() | nil) :: any
  def create!(payments, options \\ []) do
    Rest.post!(
      resource(),
      payments,
      options
    )
  end

  @doc """
  Receive a single IssPayment struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - IssPayment struct with updated attributes
  """
  @spec get(binary, user: Project.t() | nil) :: {:ok, IssPayment.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | nil) :: IssPayment.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a single IssPayment pdf file generated in the Stark Bank API by passing its id.
  Only valid for ISS payments with "success" status.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - IssPayment pdf file content
  """
  @spec pdf(binary, user: Project.t() | nil) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(id, options \\ []) do
    Rest.get_pdf(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(binary, user: Project.t() | nil) :: binary
  def pdf!(id, options \\ []) do
    Rest.get_pdf!(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Receive a stream of IssPayment structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date, DateTime or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date, DateTime or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid"
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of IssPayment structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | DateTime.t() | binary,
          before: Date.t() | DateTime.t() | binary,
          tags: [binary],
          ids: [binary],
          status: binary,
          user: Project.t()
        ) ::
          ({:cont, {:ok, [IssPayment.t()]}}
           | {:error, [Error.t()]}
           | {:halt, any}
           | {:suspend, any},
           any ->
             any)
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
          limit: integer,
          after: Date.t() | DateTime.t() | binary,
          before: Date.t() | DateTime.t() | binary,
          tags: [binary],
          ids: [binary],
          status: binary,
          user: Project.t()
        ) ::
          ({:cont, [IssPayment.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Delete a IssPayment entity previously created in the Stark Bank API

  ## Parameters (required):
    - `id` [string]: IssPayment unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - deleted IssPayment with updated attributes
  """
  @spec delete(binary, user: Project.t() | nil) :: {:ok, IssPayment.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t() | nil) :: IssPayment.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "IssPayment",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %IssPayment{
      line: json[:line],
      bar_code: json[:bar_code],
      description: json[:description],
      scheduled: json[:scheduled] |> Check.datetime(),
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      amount: json[:amount],
      fee: json[:fee],
      created: json[:created] |> Check.datetime()
    }
  end
end
