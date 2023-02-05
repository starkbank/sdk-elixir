defmodule StarkBank.DictKey do
  alias __MODULE__, as: DictKey
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups DictKey related functions
  """

  @doc """
  DictKey represents a PIX key registered in Bacen's DICT system.

  ## Parameters (optional):
    - `:id` [string]: DictKey object unique id and PIX key itself. ex: "tony@starkbank.com", "722.461.430-04", "20.018.183/0001-80", "+5511988887777", "b6295ee1-f054-47d1-9e90-ee57b74f60d9"

    ## Attributes (return-only):
    - `:type` [string]: DICT key type. ex: "email", "cpf", "cnpj", "phone" or "evp"
    - `:name` [string]: key owner full name. ex: "Tony Stark"
    - `:tax_id` [string]: key owner tax ID (CNPJ or masked CPF). ex: "***.345.678-**" or "20.018.183/0001-80"
    - `:owner_type` [string]: DICT key owner type. ex "naturalPerson" or "legalPerson"
    - `:bank_name` [string]: bank name associated with the DICT key. ex: "Stark Bank"
    - `:ispb` [string]: bank ISPB associated with the DICT key. ex: "20018183"
    - `:branch_code` [string]: bank account branch code associated with the DICT key. ex: "9585"
    - `:account_number` [string]: bank account number associated with the DICT key. ex: "9828282578010513"
    - `:account_type` [string]: bank account type associated with the DICT key. ex: "checking", "saving", "salary" or "payment"
    - `:status` [string]: current DICT key status. ex: "created", "registered", "canceled" or "failed"
    - `:account_created` [datetime.datetime]: creation datetime of the bank account associated with the DICT key. ex: datetime.date(2020, 1, 12, 11, 14, 8)
    - `:owned` [DateTime]: datetime since when the current owner hold this DICT key. ex: ~U[2020-11-26 17:31:45.482618Z]
    - `:created` [DateTime]: creation datetime for the DICT key. ex: ~U[2020-11-26 17:31:45.482618Z]
  """
  defstruct [
    :id,
    :type,
    :name,
    :tax_id,
    :owner_type,
    :bank_name,
    :ispb,
    :branch_code,
    :account_number,
    :account_type,
    :status,
    :account_created,
    :owned,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single DictKey struct by passing its id

  ## Parameters (required):
    - `:id` [string]: DictKey object unique id and PIX key itself. ex: "tony@starkbank.com", "722.461.430-04", "20.018.183/0001-80", "+5511988887777", "b6295ee1-f054-47d1-9e90-ee57b74f60d9"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - DictKey struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, DictKey.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: DictKey.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

@doc """
  Receive a stream of DictKey structs associated with your Stark Bank Workspace

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:type` [string, default nil]: DictKey type. ex: "cpf", "cnpj", "phone", "email" or "evp"
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "registered"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of DictKey structs with updated attributes
  """
  @spec query(
          limit: integer,
          type: binary,
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [DictKey.t()]}}
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
          type: binary,
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [DictKey.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 DictKey objects previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:type` [string, default nil]: DictKey type. ex: "cpf", "cnpj", "phone", "email" or "evp"
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:status` [string, default nil]: filter for status of retrieved structs. ex: "registered"
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of DictKey structs with updated attributes and cursor to retrieve the next page of DictKey objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          type: binary,
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [DictKey.t()]}} | {:error, [%Error{}]}
  def page(options \\ []) do
    Rest.get_page(resource(), options)
  end

  @doc """
  Same as page(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec page!(
          cursor: binary,
          limit: integer,
          type: binary,
          after: Date.t() | binary,
          before: Date.t() | binary,
          ids: [binary],
          status: binary,
          user: Project.t() | Organization.t()
          ) ::
            [DictKey.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "DictKey",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %DictKey{
      id: json[:id],
      type: json[:type],
      name: json[:name],
      tax_id: json[:tax_id],
      owner_type: json[:owner_type],
      bank_name: json[:bank_name],
      ispb: json[:ispb],
      branch_code: json[:branch_code],
      account_number: json[:account_number],
      account_type: json[:account_type],
      status: json[:status],
      account_created: json[:account_created] |> Check.datetime(),
      owned: json[:owned] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
