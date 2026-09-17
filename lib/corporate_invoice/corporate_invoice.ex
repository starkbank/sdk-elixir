defmodule StarkBank.CorporateInvoice do
  alias __MODULE__, as: CorporateInvoice
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups CorporateInvoice related functions
  """

  @doc """
  The CorporateInvoice structs created in your Workspace load your Corporate balance when paid.
  When you initialize a CorporateInvoice, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the struct to the Stark Bank API
  and returns the created struct.

  ## Parameters (required):
    - `:amount` [integer]: CorporateInvoice value in cents. ex: 1234 (= R$ 12.34)

  ## Parameters (optional):
    - `:tags` [list of strings, default []]: list of strings for tagging. ex: ["travel", "food"]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when CorporateInvoice is created. ex: "5656565656565656"
    - `:name` [string, default nil]: payer name. ex: "Iron Bank S.A."
    - `:tax_id` [string, default nil]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:brcode` [string, default nil]: BR Code for the Invoice payment. ex: "00020101021226930014br.gov.bcb.pix2571brcode-h.development.starkbank.com/v2/d7f6546e194d4c64a153e8f79f1c41ac5204000053039865802BR5925Stark Bank S.A. - Institu6009Sao Paulo62070503***63042109"
    - `:due` [DateTime or Date, default nil]: Invoice due and expiration date in UTC ISO format. ex: ~U[2020-10-28 17:59:26.249976Z]
    - `:link` [string, default nil]: public Invoice webpage URL. ex: "https://starkbank-card-issuer.development.starkbank.com/invoicelink/d7f6546e194d4c64a153e8f79f1c41ac"
    - `:status` [string, default nil]: current CorporateInvoice status. ex: "created", "expired", "overdue", "paid"
    - `:corporate_transaction_id` [string, default nil]: ledger transaction ids linked to this CorporateInvoice. ex: "corporate-invoice/5656565656565656"
    - `:updated` [DateTime, default nil]: latest update datetime for the CorporateInvoice. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:created` [DateTime, default nil]: creation datetime for the CorporateInvoice. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:amount]
  defstruct [
    :amount,
    :tax_id,
    :name,
    :tags,
    :id,
    :brcode,
    :due,
    :link,
    :status,
    :corporate_transaction_id,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a single CorporateInvoice struct for creation in the Stark Bank API

  ## Parameters (required):
    - `invoice` [CorporateInvoice struct]: CorporateInvoice struct to be created in the API.

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateInvoice struct with updated attributes
  """
  @spec create(CorporateInvoice.t() | map, user: Project.t() | Organization.t() | nil) ::
          {:ok, CorporateInvoice.t()} | {:error, [Error.t()]}
  def create(invoice, options \\ []) do
    Rest.post_single(resource(), invoice, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(CorporateInvoice.t() | map, user: Project.t() | Organization.t() | nil) :: CorporateInvoice.t()
  def create!(invoice, options \\ []) do
    Rest.post_single!(resource(), invoice, options)
  end

  @doc """
  Receive a stream of CorporateInvoice structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "expired", "overdue", "paid"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateInvoice structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: [binary],
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [CorporateInvoice.t()]}}
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
          status: [binary],
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [CorporateInvoice.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CorporateInvoice structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of structs to be retrieved. Max = 100. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["created", "expired", "overdue", "paid"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateInvoice structs with updated attributes and cursor to retrieve the next page of CorporateInvoice objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: [binary],
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {binary, [CorporateInvoice.t()]}} | {:error, [%Error{}]}
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
          status: [binary],
          tags: [binary],
          user: Project.t() | Organization.t()
        ) ::
          [CorporateInvoice.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "CorporateInvoice",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CorporateInvoice{
      amount: json[:amount],
      tax_id: json[:tax_id],
      name: json[:name],
      tags: json[:tags],
      id: json[:id],
      brcode: json[:brcode],
      due: json[:due] |> Check.date_or_datetime(),
      link: json[:link],
      status: json[:status],
      corporate_transaction_id: json[:corporate_transaction_id],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
