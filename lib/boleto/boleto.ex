defmodule StarkBank.Boleto do
  alias __MODULE__, as: Boleto
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups Boleto related functions
  """

  @doc """
  When you initialize a Boleto struct, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:amount` [integer]: Boleto value in cents. Minimum amount = 200 (R$2,00). ex: 1234 (= R$ 12.34)
    - `:name` [string]: payer full name. ex: "Anthony Edward Stark"
    - `:tax_id` [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:street_line_1` [string]: payer main address. ex: Av. Paulista, 200
    - `:street_line_2` [string]: payer address complement. ex: Apto. 123
    - `:district` [string]: payer address district / neighbourhood. ex: Bela Vista
    - `:city` [string]: payer address city. ex: Rio de Janeiro
    - `:state_code` [string]: payer address state. ex: GO
    - `:zip_code` [string]: payer address zip code. ex: 01311-200

  ## Parameters (optional):
    - `:due` [Date, DateTime or string, default today + 2 days]: Boleto due date in ISO format. ex: 2020-04-30
    - `:fine` [float, default 0.0]: Boleto fine for overdue payment in %. ex: 2.5
    - `:interest` [float, default 0.0]: Boleto monthly interest for overdue payment in %. ex: 5.2
    - `:overdue_limit` [integer, default 59]: limit in days for payment after due date. ex: 7 (max: 59)
    - `:receiver_name` [string]: receiver (Sacador Avalista) full name. ex: "Anthony Edward Stark"
    - `:receiver_tax_id` [string]: receiver (Sacador Avalista) tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:descriptions` [list of maps, default nil]: list of maps with :text (string) and :amount (int, optional) pairs
    - `:discounts` [list of maps, default nil]: list of maps with :percentage (float) and :date (Date or string) pairs
    - `:tags` [list of strings]: list of strings for tagging

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when Boleto is created. ex: "5656565656565656"
    - `:fee` [integer, default nil]: fee charged when Boleto is paid. ex: 200 (= R$ 2.00)
    - `:line` [string, default nil]: generated Boleto line for payment. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    - `:bar_code` [string, default nil]: generated Boleto bar-code for payment. ex: "34195819600000000621090063571277307144464000"
    - `:status` [string, default nil]: current Boleto status. ex: "registered" or "paid"
    - `:created` [DateTime, default nil]: creation datetime for the Boleto. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [
    :amount,
    :name,
    :tax_id,
    :street_line_1,
    :street_line_2,
    :district,
    :city,
    :state_code,
    :zip_code
  ]
  defstruct [
    :amount,
    :name,
    :tax_id,
    :street_line_1,
    :street_line_2,
    :district,
    :city,
    :state_code,
    :zip_code,
    :due,
    :fine,
    :interest,
    :overdue_limit,
    :receiver_name,
    :receiver_tax_id,
    :tags,
    :descriptions,
    :discounts,
    :id,
    :fee,
    :line,
    :bar_code,
    :status,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of Boleto structs for creation in the Stark Bank API

  ## Parameters (required):
    - `boletos` [list of Boleto structs]: list of Boleto structs to be created in the API

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - list of Boleto structs with updated attributes
  """
  @spec create([Boleto.t() | map()], user: Project.t() | nil) ::
          {:ok, [Boleto.t()]} | {:error, [Error.t()]}
  def create(boletos, options \\ []) do
    Rest.post(
      resource(),
      boletos,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([Boleto.t() | map()], user: Project.t() | nil) :: any
  def create!(boletos, options \\ []) do
    Rest.post!(
      resource(),
      boletos,
      options
    )
  end

  @doc """
  Receive a single Boleto struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Boleto struct with updated attributes
  """
  @spec get(binary, user: Project.t() | nil) :: {:ok, Boleto.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | nil) :: Boleto.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a single Boleto pdf file generated in the Stark Bank API by passing its id.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:layout` [string]: Layout specification. Available options are "default" and "booklet".
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Boleto pdf file content
  """
  @spec pdf(binary, layout: binary, user: Project.t() | nil) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(id, options \\ []) do
    Rest.get_pdf(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(binary, layout: binary, user: Project.t() | nil) :: binary
  def pdf!(id, options \\ []) do
    Rest.get_pdf!(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Receive a stream of Boleto structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date, DateTime or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date, DateTime or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of Boleto structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | DateTime.t() | binary,
          before: Date.t() | DateTime.t() | binary,
          status: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t()
        ) ::
          ({:cont, {:ok, [Boleto.t()]}}
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
          status: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t()
        ) ::
          ({:cont, [Boleto.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Delete a list of Boleto entities previously created in the Stark Bank API

  ## Parameters (required):
    - `id` [string]: Boleto unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ##  Return:
    - deleted Boleto struct
  """
  @spec delete(binary, user: Project.t() | nil) :: {:ok, Boleto.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t() | nil) :: Boleto.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
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
    %Boleto{
      amount: json[:amount],
      name: json[:name],
      tax_id: json[:tax_id],
      street_line_1: json[:street_line_1],
      street_line_2: json[:street_line_2],
      district: json[:district],
      city: json[:city],
      state_code: json[:state_code],
      zip_code: json[:zip_code],
      due: json[:due] |> Check.datetime(),
      fine: json[:fine],
      interest: json[:interest],
      overdue_limit: json[:overdue_limit],
      receiver_name: json[:receiver_name],
      receiver_tax_id: json[:receiver_tax_id],
      tags: json[:tags],
      descriptions: json[:descriptions],
      discounts: json[:discounts],
      id: json[:id],
      fee: json[:fee],
      line: json[:line],
      bar_code: json[:bar_code],
      status: json[:status],
      created: json[:created] |> Check.datetime()
    }
  end
end
