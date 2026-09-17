defmodule StarkBank.CorporateCard do
  alias __MODULE__, as: CorporateCard
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error
  alias StarkBank.CorporateRule

  @moduledoc """
  Groups CorporateCard related functions
  """

  @doc """
  The CorporateCard struct displays the information of the cards created in your Workspace.
  Sensitive information will only be returned when the `:expand` option is used, to avoid
  security concerns. When you initialize a CorporateCard, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the struct to the Stark Bank API
  and returns the created struct.

  ## Parameters (required):
    - `:holder_id` [string]: card holder unique id. ex: "5656565656565656"

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when CorporateCard is created. ex: "5656565656565656"
    - `:holder_name` [string, default nil]: card holder name. ex: "Tony Stark"
    - `:display_name` [string, default nil]: card displayed name. ex: "ANTHONY STARK"
    - `:rules` [list of CorporateRule structs, default nil]: [EXPANDABLE] list of card spending rules.
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["travel", "food"]
    - `:street_line_1` [string, default nil]: card holder main address. ex: "Av. Paulista, 200"
    - `:street_line_2` [string, default nil]: card holder address complement. ex: "Apto. 123"
    - `:district` [string, default nil]: card holder address district/neighbourhood. ex: "Bela Vista"
    - `:city` [string, default nil]: card holder address city. ex: "Rio de Janeiro"
    - `:state_code` [string, default nil]: card holder address state. ex: "GO"
    - `:zip_code` [string, default nil]: card holder address zip code. ex: "01311-200"
    - `:type` [string, default nil]: card type. ex: "virtual"
    - `:status` [string, default nil]: current CorporateCard status. ex: "active", "blocked", "canceled", "expired"
    - `:number` [string, default nil]: [EXPANDABLE] masked card number. Expand to unmask the value. ex: "123"
    - `:security_code` [string, default nil]: [EXPANDABLE] masked card verification value (cvv). Expand to unmask the value. ex: "123"
    - `:expiration` [DateTime, default nil]: [EXPANDABLE] masked card expiration datetime. Expand to unmask the value. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the CorporateCard. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:created` [DateTime, default nil]: creation datetime for the CorporateCard. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:holder_id]
  defstruct [
    :holder_id,
    :id,
    :holder_name,
    :display_name,
    :rules,
    :tags,
    :street_line_1,
    :street_line_2,
    :district,
    :city,
    :state_code,
    :zip_code,
    :type,
    :status,
    :number,
    :security_code,
    :expiration,
    :updated,
    :created
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Send a CorporateCard struct for creation in the Stark Bank API.
  If the CorporateCard was not used in the last purchase, this resource will return it.

  ## Parameters (required):
    - `card` [CorporateCard struct]: CorporateCard struct to be created in the API.

  ## Options:
    - `:expand` [list of strings, default nil]: fields to expand information. Options: ["rules", "security_code", "number", "expiration"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateCard struct with updated attributes
  """
  @spec create(CorporateCard.t() | map, expand: [binary], user: Project.t() | Organization.t() | nil) ::
          {:ok, CorporateCard.t()} | {:error, [Error.t()]}
  def create(card, options \\ []) do
    Rest.post_single_to_sub_path(resource(), "token", card, options)
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(CorporateCard.t() | map, expand: [binary], user: Project.t() | Organization.t() | nil) :: CorporateCard.t()
  def create!(card, options \\ []) do
    Rest.post_single_to_sub_path!(resource(), "token", card, options)
  end

  @doc """
  Receive a single CorporateCard struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:expand` [list of strings, default nil]: fields to expand information. Options: ["rules", "security_code", "number", "expiration"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateCard struct with updated attributes
  """
  @spec get(binary, expand: [binary], user: Project.t() | Organization.t() | nil) ::
          {:ok, CorporateCard.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, expand: [binary], user: Project.t() | Organization.t() | nil) :: CorporateCard.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of CorporateCard structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["active", "blocked", "canceled", "expired"]
    - `:types` [list of strings, default nil]: card type. ex: ["virtual"]
    - `:holder_ids` [list of strings, default nil]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:expand` [list of strings, default nil]: fields to expand information. Options: ["rules", "security_code", "number", "expiration"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateCard structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: [binary],
          types: [binary],
          holder_ids: [binary],
          ids: [binary],
          tags: [binary],
          expand: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [CorporateCard.t()]}}
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
          types: [binary],
          holder_ids: [binary],
          ids: [binary],
          tags: [binary],
          expand: [binary],
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [CorporateCard.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Receive a list of up to 100 CorporateCard structs previously created in the Stark Bank API and the cursor to the next page.
  Use this function instead of query if you want to manually page your requests.

  ## Options:
    - `:cursor` [string, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of strings, default nil]: filter for status of retrieved structs. ex: ["active", "blocked", "canceled", "expired"]
    - `:types` [list of strings, default nil]: card type. ex: ["virtual"]
    - `:holder_ids` [list of strings, default nil]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
    - `:expand` [list of strings, default nil]: fields to expand information. Options: ["rules", "security_code", "number", "expiration"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateCard structs with updated attributes and cursor to retrieve the next page of CorporateCard objects
  """
  @spec page(
          cursor: binary,
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          status: [binary],
          types: [binary],
          holder_ids: [binary],
          ids: [binary],
          tags: [binary],
          expand: [binary],
          user: Project.t() | Organization.t()
          ) ::
            {:ok, {binary, [CorporateCard.t()]}} | {:error, [%Error{}]}
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
          types: [binary],
          holder_ids: [binary],
          ids: [binary],
          tags: [binary],
          expand: [binary],
          user: Project.t() | Organization.t()
          ) ::
            [CorporateCard.t()]
  def page!(options \\ []) do
    Rest.get_page!(resource(), options)
  end

  @doc """
  Update a CorporateCard by passing its id.

  ## Parameters (required):
    - `id` [string]: CorporateCard id. ex: "5656565656565656"

  ## Options:
    - `:status` [string, default nil]: you may block the CorporateCard by passing "blocked" or activate by passing "active" in the status
    - `:display_name` [string, default nil]: card displayed name. ex: "ANTHONY EDWARD"
    - `:pin` [string, default nil]: you may unlock your physical card by passing its PIN. This is also the PIN you use to authorize a purchase.
    - `:rules` [list of CorporateRule structs, default nil]: list of CorporateRule structs to be updated.
    - `:tags` [list of strings, default nil]: list of strings for tagging. ex: ["tony", "stark"]
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target CorporateCard with updated attributes
  """
  @spec update(binary,
          status: binary,
          display_name: binary,
          pin: binary,
          rules: [CorporateRule.t() | map],
          tags: [binary],
          user: Project.t() | Organization.t() | nil
        ) :: {:ok, CorporateCard.t()} | {:error, [%Error{}]}
  def update(id, parameters \\ []) do
    Rest.patch_id(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(binary,
          status: binary,
          display_name: binary,
          pin: binary,
          rules: [CorporateRule.t() | map],
          tags: [binary],
          user: Project.t() | Organization.t() | nil
        ) :: CorporateCard.t()
  def update!(id, parameters \\ []) do
    Rest.patch_id!(resource(), id, parameters |> Enum.into(%{}))
  end

  @doc """
  Cancel a CorporateCard entity previously created in the Stark Bank API

  ## Parameters (required):
    - `id` [string]: CorporateCard unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled CorporateCard struct
  """
  @spec cancel(binary, user: Project.t() | Organization.t() | nil) :: {:ok, CorporateCard.t()} | {:error, [%Error{}]}
  def cancel(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(binary, user: Project.t() | Organization.t() | nil) :: CorporateCard.t()
  def cancel!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
  end

  @doc false
  def resource() do
    {
      "CorporateCard",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CorporateCard{
      holder_id: json[:holder_id],
      id: json[:id],
      holder_name: json[:holder_name],
      display_name: json[:display_name],
      rules: json[:rules] |> CorporateRule.parse_rules(),
      tags: json[:tags],
      street_line_1: json[:street_line_1],
      street_line_2: json[:street_line_2],
      district: json[:district],
      city: json[:city],
      state_code: json[:state_code],
      zip_code: json[:zip_code],
      type: json[:type],
      status: json[:status],
      number: json[:number],
      security_code: json[:security_code],
      expiration: json[:expiration] |> parse_expiration(),
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end

  # The API always sends an `expiration` key, masking it with "*" characters
  # whenever the field is not expanded. Check.datetime/1 has no mask guard, so
  # it must be bypassed here or every non-expanded read would raise.
  defp parse_expiration(value) when is_binary(value) do
    if String.contains?(value, "*") do
      nil
    else
      value |> Check.datetime()
    end
  end

  defp parse_expiration(value), do: value |> Check.datetime()
end
