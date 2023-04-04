defmodule StarkBank.CorporateInvoice do
  alias __MODULE__, as: CorporateInvoice
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
    # CorporateInvoice object
  """

  @doc """
  The CorporateInvoice objects created in your Workspace load your Corporate balance when paid.

  ## Parameters (required):
    - `:amount` [integer]: CorporateInvoice value in cents. ex: 1234 (= R$ 12.34)

  ## Parameters (optional):
    - `:tags` [list of binaries, default []]: list of binaries for tagging. ex: ["travel", "food"]

  ## Attributes (return-only):
    - `:id` [binary]: unique id returned when CorporateInvoice is created. ex: "5656565656565656"
    - `:name` [binary, default sub-issuer name]: payer name. ex: "Iron Bank S.A."
    - `:tax_id` [binary, default sub-issuer tax ID]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:brcode` [binary]: BR Code for the Invoice payment. ex: "00020101021226930014br.gov.bcb.pix2571brcode-h.development.starkbank.com/v2/d7f6546e194d4c64a153e8f79f1c41ac5204000053039865802BR5925Stark Bank S.A. - Institu6009Sao Paulo62070503***63042109"
    - `:due` [Date, DateTime or binary]: Invoice due and expiration date in UTC ISO format. ex: "2020-10-28T17:59:26.249976+00:00"
    - `:link` [binary]: public Invoice webpage URL. ex: "https://starkbank-card-issuer.development.starkbank.com/invoicelink/d7f6546e194d4c64a153e8f79f1c41ac"
    - `:status` [binary]: current CorporateInvoice status. Options: "created", "expired", "overdue", "paid"
    - `:corporate_transaction_id` [binary]: ledger transaction ids linked to this CorporateInvoice. ex: "corporate-invoice/5656565656565656"
    - `:updated` [DateTime]: latest update DateTime for the CorporateInvoice. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the CorporateInvoice. ex: ~U[2020-03-10 10:30:0:0]
  """
  @enforce_keys [
    :amount
  ]
  defstruct [
    :id,
    :amount,
    :tags,
    :tax_id,
    :name,
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
  Send a list of CorporateInvoice objects for creation in the Stark Bank API

  ## Parameters (required):
    - `:invoice` [CorporateInvoice object]: CorporateInvoice object to be created in the API.

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateInvoice object with updated attributes
  """
  @spec create(
    invoice: CorporateInvoice.t(),
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, CorporateInvoice.t()} |
    {:error, [Error.t()]}
  def create(invoice, options \\ []) do
    Rest.post_single(
      resource(),
      invoice,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(
    invoice: CorporateInvoice.t(),
    user: Organization.t() | Project.t() | nil
  ) :: any
  def create!(invoice, options \\ []) do
    Rest.post_single!(
      resource(),
      invoice,
      options
    )
  end

  @doc """
  Receive a stream of CorporateInvoice objects previously created in the Stark Bank API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "expired", "overdue", "paid"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateInvoice objects with updated attributes
  """
  @spec query(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [CorporateInvoice.t()]}} |
    {:error, [Error.t()]}
  def query(options \\ []) do
    Rest.get_list(
      resource(),
      options
    )
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of up to 100 CorporateInvoice objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["created", "expired", "overdue", "paid"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateInvoice objects with updated attributes
    - cursor to retrieve the next page of CorporateInvoice objects
  """
  @spec page(
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) ::
    {:ok, {binary, [CorporateInvoice.t()]}} |
    {:error, [Error.t()]}
  def page(options \\ []) do
    Rest.get_page(
      resource(),
      options
    )
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
    cursor: binary | nil,
    limit: integer | nil,
    after: Date.t() | binary | nil,
    before: Date.t() | binary | nil,
    status: [binary] | nil,
    tags: [binary] | nil,
    user: Organization.t() | Project.t() | nil
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
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
      tags: json[:tags],
      id: json[:id],
      name: json[:name],
      tax_id: json[:tax_id],
      brcode: json[:brcode],
      due: json[:due],
      link: json[:link],
      status: json[:status],
      corporate_transaction_id: json[:corporate_transaction_id],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
