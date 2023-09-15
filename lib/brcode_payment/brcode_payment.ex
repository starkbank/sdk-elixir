defmodule StarkBank.BrcodePayment do
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.BrcodePayment
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups BrcodePayment related functions
  """

  @doc """
  When you initialize a BrcodePayment, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - `:brcode` [string]: String loaded directly from the QRCode or copied from the invoice. ex: "00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A"
    - `:tax_id` [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - `:description` [string]: Text to be displayed in your statement (min. 10 characters). ex: "payment ABC"

  ## Parameters (conditionally required):
    - `:amount` [int, default nil]: If the BR Code does not provide an amount, this parameter is mandatory, else it is optional. ex: 23456 (= R$ 234.56)

  ## Parameters (optional):
    - `:scheduled` [Date, DateTime or string, default now]: payment scheduled date or datetime. ex: "2020-12-13T18:36:18.219000+00:00"
    - `:tags` [list of strings]: list of strings for tagging.

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when payment is created. ex: "5656565656565656"
    - `:name` [string, default nil]: receiver name. ex: "Jon Snow"
    - `:status` [string, default nil]: current payment status. ex: "success" or "failed"
    - `:type` [string, default nil]: brcode type. ex: "static" or "dynamic"
    - `:fee` [integer, default nil]: fee charged when a brcode payment is created. ex: 200 (= R$ 2.00)
    - `:transaction_ids` [list of strings, default nil]: ledger transaction ids linked to this BR Code payment. ex: ["19827356981273"]
    - `:created` [DateTime, default nil]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the Deposit. ex: ~U[2020-08-20 19:32:35.418698Z]
  """
  @enforce_keys [:brcode, :tax_id, :description]
  defstruct [
    :brcode,
    :tax_id,
    :description,
    :amount,
    :scheduled,
    :tags,
    :id,
    :name,
    :status,
    :type,
    :fee,
    :transaction_ids,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of BrcodePayment structs for creation in the Stark Bank API

  ## Parameters (required):
    - `payments` [list of BrcodePayment structs]: list of BrcodePayment structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BrcodePayment structs with updated attributes
  """
  @spec create([BrcodePayment.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [BrcodePayment.t()]} | {:error, [Error.t()]}
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
  @spec create!([BrcodePayment.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(payments, options \\ []) do
    Rest.post!(
      resource(),
      payments,
      options
    )
  end

  @doc """
  Receive a single BrcodePayment struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - BrcodePayment struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, BrcodePayment.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: BrcodePayment.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a single BrcodePayment pdf file generated in the Stark Bank API by passing its id.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - BrcodePayment pdf file content
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
  Receive a stream of BrcodePayment structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of BrcodePayment structs with updated attributes
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
          ({:cont, {:ok, [BrcodePayment.t()]}}
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
          ({:cont, [BrcodePayment.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 BrcodePayment objects previously created in the Stark Bank API and the cursor to the next page. 
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of BrcodePayment structs with updated attributes and cursor to retrieve the next page of BrcodePayment objects
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
            {:ok, {binary, [BrcodePayment.t()]}} | {:error, [%Error{}]} 
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
            [BrcodePayment.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end  

  @doc """
  Update an BrcodePayment by passing id, if it hasn't been paid yet.

  ## Parameters (required):
    - `:id` [string]: BrcodePayment id. ex: '5656565656565656'

  ## Parameters (optional):
    - `:status` [string]: You may cancel the BrcodePayment by passing "canceled" in the status
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target BrcodePayment with updated attributes
  """
  @spec update(binary, status: binary, user: Project.t() | Organization.t() | nil) ::
          {:ok, BrcodePayment.t()} | {:error, [%Error{}]}
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(binary, status: binary, user: Project.t() | Organization.t() | nil) :: BrcodePayment.t()
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc false
  def resource() do
    {
      "BrcodePayment",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BrcodePayment{
      brcode: json[:brcode],
      tax_id: json[:tax_id],
      description: json[:description],
      amount: json[:amount],
      scheduled: json[:scheduled] |> Check.datetime(),
      tags: json[:tags],
      id: json[:id],
      name: json[:name],
      status: json[:status],
      type: json[:type],
      fee: json[:fee],
      transaction_ids: json[:transaction_ids],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
