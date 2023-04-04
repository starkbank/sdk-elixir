defmodule StarkBank.TaxPayment do
  alias __MODULE__, as: TaxPayment
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups TaxPayment related functions
  """

  @doc """
  When you initialize a TaxPayment, the entity will not be automatically
  created in the Stark Bank API. The "create" function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (conditionally required):
    - `:line` [string, default nil]: Number sequence that describes the payment. Either "line" or "bar_code" parameters are required. If both are sent, they must match. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    - `:bar_code` [string, default nil]: Bar code number that describes the payment. Either "line" or "bar_code" parameters are required. If both are sent, they must match. ex: "34195819600000000621090063571277307144464000"

  ## Parameters (required):
    - `:description` [string]: Text to be displayed in your statement (min. 10 characters). ex: "payment ABC"

  ## Parameters (optional):
    - `:scheduled` [string, default today]: payment scheduled date. ex: "2020-03-10"
    - `:tags` [list of strings]: list of strings for tagging

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when payment is created. ex: "5656565656565656"
    - `:type` [string]: tax type. ex: "das"
    - `:status` [string]: current payment status. ex: "success" or "failed"
    - `:amount` [int]: amount automatically calculated from line or bar_code. ex: 23456 (= R$ 234.56)
    - `:fee` [integer]: fee charged when the tax payment is created. ex: 200 (= R$ 2.00)
    - `:transaction_ids` [list of strings]: list of strings for taggingledger transaction ids linked to this TaxPayment. ex: ["19827356981273"]
    - `:updated` [string]: latest update datetime for the payment. ex: "2020-03-10 10:30:00.000"
    - `:created` [string]: creation datetime for the payment. ex: "2020-03-10 10:30:00.000"
  """
  @enforce_keys [
    :description
  ]
  defstruct [
    :description,
    :scheduled,
    :line,
    :bar_code,
    :tags,
    :amount,
    :status,
    :type,
    :updated,
    :created,
    :fee,
    :transaction_ids,
    :id
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of TaxPayment structs for creation in the Stark Bank API

  ## Parameters (required):
    - `:payments` [list of TaxPayment structs]: list of TaxPayment structs to be created in the API

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of TaxPayment structs with updated attributes
  """
  @spec create([TaxPayment.t() | map()], user: Project.t() | Organization.t() | nil) ::
      {:ok, [TaxPayment.t()]} | {:error, [Error.t()]}
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
  @spec create!([TaxPayment.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(payments, options \\ []) do
    Rest.post!(
      resource(),
      payments,
      options
    )
  end

  @doc """
  Receive a single TaxPayment struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `:id` [string]: entity unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - TaxPayment struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, TaxPayment.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: TaxPayment.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of TaxPayment entities previously created in the Stark Bank API

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for entities created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for entities created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ['5656565656565656', '4545454545454545']
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: 'success'
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of TaxPayment structs with updated attributes
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
      ({:cont, {:ok, [TaxPayment.t()]}}
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
      ({:cont, [TaxPayment.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 TaxPayment structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Parameters (optional):
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for entities created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for entities created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ['5656565656565656', '4545454545454545']
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: 'success'
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of TaxPayment structs with updated attributes and cursor to retrieve the next page of TaxPayment structs
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
        {:ok, {binary, [TaxPayment.t()]}} | {:error, [%Error{}]}
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
        [TaxPayment.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end


  @doc """
  Receive a single Transfer pdf receipt file generated in the Stark Bank API by passing its id.
  Only valid for transfers with "processing" or "success" status.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - Transfer pdf file content
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
  Delete a TaxPayment entity previously created in the Stark Bank API

  ## Parameters (required):
    - `:id` [string]: Boleto unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ##  Return:
    - deleted TaxPayment struct
  """
  @spec delete(binary, user: Project.t() | Organization.t() | nil) :: {:ok, TaxPayment.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t() | Organization.t() | nil) :: TaxPayment.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "TaxPayment",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %TaxPayment{
      description: json[:description],
      scheduled: json[:scheduled] |> Check.datetime(),
      line: json[:line],
      bar_code: json[:bar_code],
      tags: json[:tags],
      amount: json[:amount],
      status: json[:status],
      type: json[:type],
      fee: json[:fee],
      transaction_ids: json[:transaction_ids],
      id: json[:id],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
