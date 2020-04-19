defmodule StarkBank.Boleto do
  alias __MODULE__, as: Boleto
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Utils.Checks, as: Checks
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error

  @moduledoc """
  Groups Boleto related functions
  """

  @doc """
  When you initialize a Boleto struct, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - amount [integer]: Boleto value in cents. Minimum amount = 200 (R$2,00). ex: 1234 (= R$ 12.34)
    - name [string]: payer full name. ex: "Anthony Edward Stark"
    - tax_id [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - street_line_1 [string]: payer main address. ex: Av. Paulista, 200
    - street_line_2 [string]: payer address complement. ex: Apto. 123
    - district [string]: payer address district / neighbourhood. ex: Bela Vista
    - city [string]: payer address city. ex: Rio de Janeiro
    - state_code [string]: payer address state. ex: GO
    - zip_code [string]: payer address zip code. ex: 01311-200
    - due [Date, default today + 2 days]: Boleto due date in ISO format. ex: 2020-04-30

  ## Parameters (optional):
    - fine [float, default 0.0]: Boleto fine for overdue payment in %. ex: 2.5
    - interest [float, default 0.0]: Boleto monthly interest for overdue payment in %. ex: 5.2
    - overdue_limit [integer, default 59]: limit in days for automatic Boleto cancellation after due date. ex: 7 (max: 59)
    - descriptions [list of maps, default nil]: list of maps with :text (string) and :amount (int, optional) pairs
    - tags [list of strings]: list of strings for tagging

  ## Attributes (return-only):
    - id [string, default nil]: unique id returned when Boleto is created. ex: "5656565656565656"
    - fee [integer, default nil]: fee charged when Boleto is paid. ex: 200 (= R$ 2.00)
    - line [string, default nil]: generated Boleto line for payment. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    - bar_code [string, default nil]: generated Boleto bar-code for payment. ex: "34195819600000000621090063571277307144464000"
    - status [string, default nil]: current Boleto status. ex: "registered" or "paid"
    - created [DateTime, default nil]: creation datetime for the Boleto. ex: ~U[2020-03-26 19:32:35.418698Z]
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
    :tags,
    :descriptions,
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
    - boletos [list of Boleto structs]: list of Boleto structs to be created in the API

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - list of Boleto structs with updated attributes
  """
  @spec create(Project.t(), [Boleto.t()]) ::
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
  @spec create!(Project.t(), [Boleto.t()]) :: any
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
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - Boleto struct with updated attributes
  """
  @spec get(Project.t(), binary) :: {:ok, Boleto.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project.t(), binary) :: Boleto.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a single Boleto pdf file generated in the Stark Bank API by passing its id.

  ## Parameters (required):
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - Boleto pdf file content
  """
  @spec pdf(Project.t(), binary) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(id, options \\ []) do
    Rest.get_pdf(resource(), id, options)
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(Project.t(), binary) :: binary
  def pdf!(id, options \\ []) do
    Rest.get_pdf!(resource(), id, options)
  end

  @doc """
  Receive a stream of Boleto structs previously created in the Stark Bank API

  ## Keyword Args:
    - limit [integer, default nil] (optional): maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - after [Date, default nil] (optional) date filter for structs created only after specified date. ex: Date(2020, 3, 10)
    - before [Date, default nil] (optional): date filter for structs only before specified date. ex: Date(2020, 3, 10)
    - status [string, default nil] (optional): filter for status of retrieved structs. ex: "paid" or "registered"
    - tags [list of strings, default nil] (optional): tags to filter retrieved structs. ex: ["tony", "stark"]
    - ids [list of strings, default nil] (optional): list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - stream of Boleto structs with updated attributes
  """
  @spec query(any) ::
          ({:cont, {:ok, [Boleto.t()]}}
           | {:error, [Error.t()]}
           | {:halt, any}
           | {:suspend, any},
           any ->
             any)
  def query(options \\ []) do
    Rest.get_list(resource(), options |> Checks.check_options(true))
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(any) ::
          ({:cont, [Boleto.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options |> Checks.check_options(true))
  end

  @doc """
  Delete a list of Boleto entities previously created in the Stark Bank API

  ## Parameters (required):
    - id [string]: Boleto unique id. ex: "5656565656565656"

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ##  Return:
    - deleted Boleto struct with updated attributes
  """
  @spec delete(Project.t(), binary) :: {:ok, Boleto.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project.t(), binary) :: Boleto.t()
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
      due: json[:due] |> Checks.check_datetime(),
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
      created: json[:created] |> Checks.check_datetime()
    }
  end
end
