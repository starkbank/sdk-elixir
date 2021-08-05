defmodule StarkBank.Invoice do
  alias __MODULE__, as: Invoice
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups Invoice related functions
  """

  @doc """
  When you initialize a Invoice struct, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:amount` [integer]: Invoice value in cents. Minimum = 0 (any value will be accepted). ex: 1234 (= R$ 12.34)
    - `:tax_id` [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:name` [string]: payer name. ex: "Iron Bank S.A."

  ## Parameters (optional):
    - `:due` [DateTime or string, default now + 2 days]: Invoice due date in UTC ISO format. ex: ~U[2021-03-26 19:32:35.418698Z]
    - `:expiration` [integer, default 59 days]: time interval in seconds between due date and expiration date. ex 123456789
    - `:fine` [float, default 0.0]: Invoice fine for overdue payment in %. ex: 2.5
    - `:interest` [float, default 0.0]: Invoice monthly interest for overdue payment in %. ex: 5.2
    - `:discounts` [list of dictionaries, default nil]: list of dictionaries with "percentage":float and "due":string pairs
    - `:tags` [list of strings, default nil]: list of strings for tagging
    - `:descriptions` [list of dictionaries, default nil]: list of dictionaries with "key":string and (optional) "value":string pairs

  ## Attributes (return-only):
    - `:pdf` [string, default nil]: public Invoice PDF URL. ex: "https://invoice.starkbank.com/pdf/d454fa4e524441c1b0c1a729457ed9d8"
    - `:link` [string, default nil]: public Invoice webpage URL. ex: "https://my-workspace.sandbox.starkbank.com/invoicelink/d454fa4e524441c1b0c1a729457ed9d8"
    - `:nominal_amount` [integer, default nil]: Invoice emission value in cents (will change if invoice is updated, but not if it's paid). ex: 400000
    - `:fine_amount` [integer, default nil]: Invoice fine value calculated over nominal_amount. ex: 20000
    - `:interest_amount` [integer, default nil]: Invoice interest value calculated over nominal_amount. ex: 10000
    - `:discount_amount` [integer, default nil]: Invoice discount value calculated over nominal_amount. ex: 3000
    - `:id` [string, default nil]: unique id returned when Invoice is created. ex: "5656565656565656"
    - `:brcode` [string, default nil]: BR Code for the Invoice payment. ex: "00020101021226800014br.gov.bcb.pix2558invoice.starkbank.com/f5333103-3279-4db2-8389-5efe335ba93d5204000053039865802BR5913Arya Stark6009Sao Paulo6220051656565656565656566304A9A0"
    - `:status` [string, default nil]: current Invoice status. ex: "created", "paid", "canceled" or "overdue"
    - `:fee` [integer, default nil]: fee charged by this Invoice. ex: 65 (= R$ 0.65)
    - `:transaction_ids` [list of strings, default nil]: ledger transaction ids linked to this boleto. ex: ["19827356981273"]
    - `:created` [DateTime, default nil]: creation datetime for the Invoice. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the Invoice. ex: ~U[2020-11-26 17:31:45.482618Z]
  """
  @enforce_keys [
    :amount,
    :tax_id,
    :name,
  ]
  defstruct [
    :amount,
    :due,
    :tax_id,
    :name,
    :expiration,
    :fine,
    :interest,
    :discounts,
    :tags,
    :descriptions,
    :pdf,
    :link,
    :nominal_amount,
    :fine_amount,
    :interest_amount,
    :discount_amount,
    :id,
    :brcode,
    :status,
    :fee,
    :transaction_ids,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of Invoice structs for creation in the Stark Bank API

  ## Parameters (required):
    - `invoices` [list of Invoice structs]: list of Invoice structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of Invoice structs with updated attributes
  """
  @spec create([Invoice.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [Invoice.t()]} | {:error, [Error.t()]}
  def create(invoices, options \\ []) do
    Rest.post(
      resource(),
      invoices,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([Invoice.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(invoices, options \\ []) do
    Rest.post!(
      resource(),
      invoices,
      options
    )
  end

  @doc """
  Receive a single Invoice struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Invoice struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Invoice.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Invoice.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a single Invoice QR Code png file generated in the Stark Bank API by passing its id.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Invoice QR Code png file content
  """
  @spec qrcode(binary, user: Project.t() | Organization.t() | nil) :: {:ok, binary} | {:error, [%Error{}]}
  def qrcode(id, options \\ []) do
    Rest.get_qrcode(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Same as qrcode(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec qrcode!(binary, user: Project.t() | Organization.t() | nil) :: binary
  def qrcode!(id, options \\ []) do
    Rest.get_qrcode!(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Receive a single Invoice pdf file generated in the Stark Bank API by passing its id.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Invoice pdf file content
  """
  @spec pdf(binary, user: Project.t() | Organization.t() | nil) :: {:ok, binary} | {:error, [%Error{}]}
  def pdf(id, options \\ []) do
    Rest.get_pdf(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Same as pdf(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec pdf!(binary, user: Project.t() | Organization.t() | nil) :: binary
  def pdf!(id, options \\ []) do
    Rest.get_pdf!(resource(), id, options |> Keyword.delete(:user), options[:user])
  end

  @doc """
  Receive a stream of Invoice structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "created", "paid", "canceled" or "overdue"
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of Invoice structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [Invoice.t()]}}
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
          status: binary,
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [Invoice.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Update an Invoice by passing id, if it hasn't been paid yet.

  ## Parameters (required):
    - `:id` [string]: Invoice id. ex: '5656565656565656'

  ## Parameters (optional):
    - `:status` [string]: You may cancel the invoice by passing "canceled" in the status
    - `:amount` [string]: Nominal amount charge by the invoice. ex: 100 (R$1.00)
    - `:due` [DateTime or string]: Invoice due date in UTC ISO format. ex: ~U[2021-03-26 19:32:35.418698Z]
    - `:expiration` [integer]: time interval in seconds between due date and expiration date. ex 123456789
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target Invoice with updated attributes
  """
  @spec update(binary, status: bool, amount: integer, due: DateTime, expiration: integer, user: Project.t() | Organization.t() | nil) ::
          {:ok, Invoice.t()} | {:error, [%Error{}]}
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(binary, status: bool, amount: integer, due: DateTime, expiration: integer, user: Project.t() | Organization.t() | nil) :: Invoice.t()
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters |> Enum.into(%{}))
  end


  @doc false
  def resource() do
    {
      "Invoice",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Invoice{
      amount: json[:amount],
      due: json[:due] |> Check.datetime(),
      tax_id: json[:tax_id],
      name: json[:name],
      expiration: json[:expiration],
      fine: json[:fine],
      interest: json[:interest],
      discounts: json[:discounts] |> Enum.map(fn discount -> %{discount | "due" => discount["due"] |> Check.datetime()} end),
      tags: json[:tags],
      descriptions: json[:descriptions],
      pdf: json[:pdf],
      link: json[:link],
      nominal_amount: json[:nominal_amount],
      fine_amount: json[:fine_amount],
      interest_amount: json[:interest_amount],
      discount_amount: json[:discount_amount],
      id: json[:id],
      brcode: json[:brcode],
      status: json[:status],
      fee: json[:fee],
      transaction_ids: json[:transaction_ids],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
