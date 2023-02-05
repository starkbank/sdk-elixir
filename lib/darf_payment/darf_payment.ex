defmodule StarkBank.DarfPayment do
  alias __MODULE__, as: DarfPayment
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups DarfPayment related functions
  """

  @doc """
  When you initialize a DarfPayment, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the objects
  to the Stark Bank API and returns the list of created objects.

  ## Parameters (required):
    - `:description` [string]: Text to be displayed in your statement (min. 10 characters). ex: "payment ABC"
    - `:revenue_code` [string]: 4-digit tax code assigned by Federal Revenue. ex: "5948"
    - `:tax_id` [tax_id]: tax id (formatted or unformatted) of the payer. ex: "12.345.678/0001-95"
    - `:competence` [Date or string]: competence month of the service. ex: ~D[2020-03-25]
    - `:nominal_amount` [int]: amount due in cents without fee or interest. ex: 23456 (= R$ 234.56)
    - `:fine_amount` [int]: fixed amount due in cents for fines. ex: 234 (= R$ 2.34)
    - `:interest_amount` [int]: amount due in cents for interest. ex: 456 (= R$ 4.56)
    - `:due` [Date or string]: due date for payment. ex: ~D[2020-03-25]

  ## Parameters (optional):
    - `:reference_number` [string]: number assigned to the region of the tax. ex: "08.1.17.00-4"
    - `:scheduled` [Date or string, default today]: payment scheduled date. ex: ~D[2020-03-25]
    - `:tags` [list of strings]: list of strings for tagging

  ## Attributes (return-only):
    - `:id` [string]: unique id returned when payment is created. ex: "5656565656565656"
    - `:status` [string]: current payment status. ex: "success" or "failed"
    - `:amount` [int]: amount automatically calculated from line or bar_code. ex: 23456 (= R$ 234.56)
    - `:fee` [integer]: fee charged when the tax payment is created. ex: 200 (= R$ 2.00)
    - `:updated` [DateTime]: latest update datetime for the Invoice. ex: ~U[2020-11-26 17:31:45.482618Z]
    - `:created` [DateTime]: creation datetime for the Invoice. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [
    :description,
    :revenue_code,
    :tax_id,
    :competence,
    :nominal_amount,
    :fine_amount,
    :interest_amount,
    :due
  ]
  defstruct [
    :revenue_code,
    :tax_id,
    :competence,
    :reference_number,
    :fine_amount,
    :interest_amount,
    :due,
    :description,
    :tags,
    :scheduled,
    :status,
    :amount,
    :nominal_amount,
    :id,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a list of DarfPayment structs for creation in the Stark Bank API

  ## Parameters (required):
    - `:payments` [list of DarfPayment structs]: list of DarfPayment structs to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DarfPayment structs with updated attributes
  """
  @spec create([DarfPayment.t() | map()], user: Project.t() | Organization.t() | nil) ::
      {:ok, [DarfPayment.t()]} | {:error, [Error.t()]}
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
  @spec create!([DarfPayment.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(payments, options \\ []) do
    Rest.post!(
      resource(),
      payments,
      options
    )
  end

  @doc """
  Receive a single DarfPayment struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `:id` [string]: entity unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - DarfPayment struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, DarfPayment.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: DarfPayment.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of DarfPayment entities previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for entities created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for entities created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ['5656565656565656', '4545454545454545']
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: 'success'
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of DarfPayment structs with updated attributes
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
      ({:cont, {:ok, [DarfPayment.t()]}}
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
      ({:cont, [DarfPayment.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 DarfPayment structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for entities created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for entities created only before specified date. ex: ~D[2020-03-25]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ['5656565656565656', '4545454545454545']
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: 'success'
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DarfPayment structs with updated attributes and cursor to retrieve the next page of DarfPayment structs
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
        {:ok, {binary, [DarfPayment.t()]}} | {:error, [%Error{}]}
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
        [DarfPayment.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end


  @doc """
  Receive a single Transfer pdf receipt file generated in the Stark Bank API by passing its id.
  Only valid for transfers with "processing" or "success" status.

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
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
  Delete a DarfPayment entity previously created in the Stark Bank API

  ## Parameters (required):
    - `:id` [string]: Boleto unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ##  Return:
    - deleted DarfPayment struct
  """
  @spec delete(binary, user: Project.t() | Organization.t() | nil) :: {:ok, DarfPayment.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t() | Organization.t() | nil) :: DarfPayment.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "DarfPayment",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %DarfPayment{
      revenue_code: json[:revenue_code],
      tax_id: json[:tax_id],
      competence: json[:competence] |> Check.datetime(),
      reference_number: json[:reference_number],
      fine_amount: json[:fine_amount],
      interest_amount: json[:interest_amount],
      due: json[:due] |> Check.datetime(),
      description: json[:description],
      tags: json[:tags],
      scheduled: json[:scheduled] |> Check.datetime(),
      status: json[:status],
      amount: json[:amount],
      nominal_amount: json[:nominal_amount],
      id: json[:id],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
