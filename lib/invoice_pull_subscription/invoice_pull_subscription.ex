defmodule StarkBank.InvoicePullSubscription do
  alias __MODULE__, as: InvoicePullSubscription
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups InvoicePullSubscription related functions
  """

  @doc """
  When you initialize an InvoicePullSubscription struct, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:start` [Date, DateTime or string]: subscription start date. ex: ~D[2022-04-01]
    - `:interval` [string]: subscription installment interval. Options: "week", "month", "quarter", "semester", "year"
    - `:pull_mode` [string]: subscription pull mode. Options: "manual", "automatic". Automatic mode will create the Invoice Pull Requests automatically
    - `:pull_retry_limit` [integer]: subscription pull retry limit. Options: 0, 3
    - `:type` [string]: subscription type. Options: "push", "qrcode", "qrcodeAndPayment", "paymentAndOrQrcode"

  ## Parameters (conditionally required):
    - `:amount` [integer, default 0]: subscription amount in cents. Required if an amount_min_limit is not informed. Minimum = 1 (R$ 0.01). ex: 100 (= R$ 1.00)
    - `:amount_min_limit` [integer, default nil]: subscription minimum amount in cents. Required if an amount is not informed. Minimum = 1 (R$ 0.01). ex: 100 (= R$ 1.00)

  ## Parameters (optional):
    - `:display_description` [string, default nil]: Invoice description to be shown to the payer. ex: "Subscription payment"
    - `:due` [Date, DateTime or string, default nil]: date by which the payer must approve or deny the subscription; defaults to 2 days after creation if not informed. Applies to every subscription type. ex: ~D[2022-04-08]
    - `:external_id` [string, default nil]: string that must be unique among all your InvoicePullSubscriptions. Duplicated external_ids will cause failures. ex: "my-external-id"
    - `:reference_code` [string, default nil]: reference code for reconciliation. ex: "REF123456"
    - `:end` [Date, DateTime or string, default nil]: subscription end date. ex: ~D[2023-04-01]
    - `:data` [map, default nil]: additional data for the subscription, required for types "push" (payer's account details), "qrcodeAndPayment" and "paymentAndOrQrcode" (immediate payment parameters); not required for type "qrcode"
    - `:name` [string, default nil]: subscription debtor name. ex: "Iron Bank S.A."
    - `:tax_id` [string, default nil]: subscription debtor tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:tags` [list of strings, default []]: list of strings for tagging

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when InvoicePullSubscription is created. ex: "5656565656565656"
    - `:status` [string, default nil]: current InvoicePullSubscription status. ex: "active", "canceled"
    - `:bacen_id` [string, default nil]: unique authentication id at the Central Bank. ex: "RR2001818320250616dtsPkBVaBYs"
    - `:brcode` [string, default nil]: Brcode string for the InvoicePullSubscription. ex: "00020101021126580014br.gov.bcb.pix0114+5599999999990210starkbank.com.br520400005303986540410000000000005802BR5913Stark Bank S.A.6009SAO PAULO62070503***6304D2B1"
    - `:created` [DateTime, default nil]: creation datetime for the InvoicePullSubscription. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the InvoicePullSubscription. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:start, :interval, :pull_mode, :pull_retry_limit, :type]
  defstruct [
    :start,
    :interval,
    :pull_mode,
    :pull_retry_limit,
    :type,
    :amount,
    :amount_min_limit,
    :display_description,
    :due,
    :external_id,
    :reference_code,
    :end,
    :data,
    :name,
    :tax_id,
    :tags,
    :id,
    :status,
    :bacen_id,
    :brcode,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of InvoicePullSubscription structs for creation in the Stark Bank API

  ## Parameters (required):
    - `subscriptions` [list of InvoicePullSubscription structs]: list of InvoicePullSubscription structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of InvoicePullSubscription structs with updated attributes
  """
  @spec create([InvoicePullSubscription.t() | map], user: Project.t() | Organization.t() | nil) ::
          {:ok, [InvoicePullSubscription.t()]} | {:error, [Error.t()]}
  def create(subscriptions, options \\ []) do
    Rest.post(resource(), subscriptions, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([InvoicePullSubscription.t() | map], user: Project.t() | Organization.t() | nil) ::
          [InvoicePullSubscription.t()]
  def create!(subscriptions, options \\ []) do
    Rest.post!(resource(), subscriptions, options)
  end

  @doc """
  Receive a single InvoicePullSubscription struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - InvoicePullSubscription struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, InvoicePullSubscription.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: InvoicePullSubscription.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of InvoicePullSubscription structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["active", "canceled"]
    - `:invoice_ids` [list of strings, default nil]: list of Invoice ids linked to the subscriptions. ex: ["5656565656565656", "4545454545454545"]
    - `:external_ids` [list of strings, default nil]: list of external_ids to filter retrieved structs. ex: ["my-external-id-1", "my-external-id-2"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of InvoicePullSubscription structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: [binary],
          invoice_ids: [binary],
          external_ids: [binary],
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [InvoicePullSubscription.t()]}}
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
          invoice_ids: [binary],
          external_ids: [binary],
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [InvoicePullSubscription.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 InvoicePullSubscription structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["active", "canceled"]
    - `:invoice_ids` [list of strings, default nil]: list of Invoice ids linked to the subscriptions. ex: ["5656565656565656", "4545454545454545"]
    - `:external_ids` [list of strings, default nil]: list of external_ids to filter retrieved structs. ex: ["my-external-id-1", "my-external-id-2"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of InvoicePullSubscription structs with updated attributes and cursor to retrieve the next page of InvoicePullSubscription objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: [binary],
          invoice_ids: [binary],
          external_ids: [binary],
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          {:ok, {binary, [InvoicePullSubscription.t()]}} | {:error, [%Error{}]}
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
          invoice_ids: [binary],
          external_ids: [binary],
          tags: [binary],
          ids: [binary],
          user: Project.t() | Organization.t()
        ) ::
          [InvoicePullSubscription.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Cancel an InvoicePullSubscription entity previously created in the Stark Bank API. The subscription
  must currently be in "active" status to be canceled.

  ## Parameters (required):
    - `id` [string]: InvoicePullSubscription unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled InvoicePullSubscription struct
  """
  @spec cancel(binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, InvoicePullSubscription.t()} | {:error, [%Error{}]}
  def cancel(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(binary, user: Project.t() | Organization.t() | nil) :: InvoicePullSubscription.t()
  def cancel!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "InvoicePullSubscription",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %InvoicePullSubscription{
      start: json[:start] |> Check.date_or_datetime(),
      interval: json[:interval],
      pull_mode: json[:pull_mode],
      pull_retry_limit: json[:pull_retry_limit],
      type: json[:type],
      amount: json[:amount],
      amount_min_limit: json[:amount_min_limit],
      display_description: json[:display_description],
      due: json[:due] |> parse_date(),
      external_id: json[:external_id],
      reference_code: json[:reference_code],
      end: json[:end] |> parse_date(),
      data: json[:data],
      name: json[:name],
      tax_id: json[:tax_id],
      tags: json[:tags],
      id: json[:id],
      status: json[:status],
      bacen_id: json[:bacen_id],
      brcode: json[:brcode],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end

  defp parse_date(""), do: nil
  defp parse_date(date), do: date |> Check.date_or_datetime()
end
