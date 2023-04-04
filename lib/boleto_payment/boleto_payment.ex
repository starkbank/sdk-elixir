defmodule StarkBank.BoletoPayment do
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.BoletoPayment
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups BoletoPayment related functions
  """

  @doc """
  When you initialize a BoletoPayment, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (conditionally required):
    - `:line` [string, default nil]: Number sequence that describes the payment. Either 'line' or 'bar_code' parameters are required. If both are sent, they must match. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    - `:bar_code` [string, default nil]: Bar code number that describes the payment. Either 'line' or 'barCode' parameters are required. If both are sent, they must match. ex: "34195819600000000621090063571277307144464000"

  ## Parameters (required):
    - `:tax_id` [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:description` [string]: Text to be displayed in your statement (min. 10 characters). ex: "payment ABC"

  ## Parameters (optional):
    - `:amount` [int]: amount automatically calculated from line or bar_code. ex: 23456 (= R$ 234.56)
    - `:scheduled` [Date or string, default today]: payment scheduled date. ex: ~D[2020-03-25]
    - `:tags` [list of strings]: list of strings for tagging

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when payment is created. ex: "5656565656565656"
    - `:status` [string]: current payment status. ex: "success" or "failed"
    - `:fee` [integer]: fee charged when a boleto payment is created. ex: 200 (= R$ 2.00)
    - `:transaction_ids` [list of strings]: ledger transaction ids linked to this BoletoPayment. ex: ["19827356981273"]
    - `:created` [DateTime]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [
    :tax_id,
    :description
  ]
  defstruct [
    :line,
    :bar_code,
    :tax_id,
    :description,
    :amount,
    :scheduled,
    :tags,
    :id,
    :status,
    :fee,
    :transaction_ids,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of BoletoPayment structs for creation in the Stark Bank API

  ## Parameters (required):
    - `payments` [list of BoletoPayment structs]: list of BoletoPayment structs to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BoletoPayment structs with updated attributes
  """
  @spec create([BoletoPayment.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [BoletoPayment.t()]} | {:error, [Error.t()]}
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
  @spec create!([BoletoPayment.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(payments, options \\ []) do
    Rest.post!(
      resource(),
      payments,
      options
    )
  end

  @doc """
  Receive a single BoletoPayment struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - BoletoPayment struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, BoletoPayment.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: BoletoPayment.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a single BoletoPayment pdf file generated in the Stark Bank API by passing its id.
  Only valid for boleto payments with "success" status.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - BoletoPayment pdf file content
  """
  @spec pdf(binary, user: Project.t() | Organization.t() | nil) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(id, options \\ []) do
    Rest.get_content(resource(), id, "pdf", options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(binary, user: Project.t() | Organization.t() | nil) :: binary
  def pdf!(id, options \\ []) do
    Rest.get_content!(resource(), id, "pdf", options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Receive a stream of BoletoPayment structs previously created in the Stark Bank API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of BoletoPayment structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [BoletoPayment.t()]}}
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
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [BoletoPayment.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 BoletoPayment objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BoletoPayment structs with updated attributes and cursor to retrieve the next page of BoletoPayment objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [BoletoPayment.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          tags: [binary],
          ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
          ) ::
            [BoletoPayment.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Delete a BoletoPayment entity previously created in the Stark Bank API

  ## Parameters (required):
    - `id` [string]: BoletoPayment unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - deleted BoletoPayment struct
  """
  @spec delete(binary, user: Project.t() | Organization.t() | nil) :: {:ok, BoletoPayment.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t() | Organization.t() | nil) :: BoletoPayment.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
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
      scheduled: json[:scheduled] |> Check.datetime(),
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      amount: json[:amount],
      fee: json[:fee],
      transaction_ids: json[:transaction_ids],
      created: json[:created] |> Check.datetime()
    }
  end
end
