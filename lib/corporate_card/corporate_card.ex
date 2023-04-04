defmodule StarkBank.CorporateCard do
  alias __MODULE__, as: CorporateCard
  alias StarkBank.CorporateRule
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.API
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
    Groups CorporateCard related functions
  """

  @doc """
  The CorporateCard object displays the information of the cards created in your Workspace.
  Sensitive information will only be returned when the "expand" parameter is used, to avoid security concerns.

  ## Parameters (required):
  - `:holder_id` [binary]: card holder tax ID. ex: "012.345.678-90"

  ## Parameters (optional):
    - `:id` [binary]: unique id returned when CorporateCard is created. ex: "5656565656565656"
    - `:holder_name` [binary]: card holder name. ex: "Tony Stark"
    - `:display_name` [binary, default nil]: card displayed name. ex: "ANTHONY STARK"
    - `:rules` [list of CorporateRule, default nil]: [EXPANDABLE] list of card spending rules.
    - `:tags` [list of binaries]: list of binaries for tagging. ex: ["travel", "food"]
    - `:street_line_1` [binary, default nil]: card holder main address. ex: "Av. Paulista, 200"
    - `:street_line_2` [binary, default nil]: card holder address complement. ex: "Apto. 123"
    - `:district` [binary, default sub-issuer district]: card holder address district / neighbourhood. ex: "Bela Vista"
    - `:city` [binary, default sub-issuer city]]: card holder address city. ex: "Rio de Janeiro"
    - `:state_code` [binary, default sub-issuer state code]: card holder address state. ex: "GO"
    - `:zip_code` [binary, default sub-issuer zip code]: card holder address zip code. ex: "01311-200"
    - `:type` [binary]: card type. ex: "virtual"
    - `:status` [binary]: current CorporateCard status. Options: "active", "blocked", "canceled", "expired"
    - `:number` [binary]: [EXPANDABLE] masked card number. Expand to unmask the value. ex: "123".
    - `:security_code` [binary]: [EXPANDABLE] masked card verification value (cvv). Expand to unmask the value. ex: "123".
    - `:expiration` [binary]: [EXPANDABLE] masked card expiration datetime. Expand to unmask the value. ex: ~U[2020-3-10 10:30:0:0]
    - `:updated` [DateTime]: latest update DateTime for the CorporateCard. ex: ~U[2020-3-10 10:30:0:0]
    - `:created` [DateTime]: creation datetime for the CorporateCard. ex: ~U[2020-03-10 10:30:0:0]
  """

  @enforce_keys [
    :holder_id,
  ]
  defstruct [
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

  # @doc """
  # Send a list of CorporateCard objects for creation in the Stark Bank API.

  # ## Parameters (required):
  #   - `:cards` [list of CorporateCard objects]: list of CorporateCard objects to be created in the API

  # ## Parameters (optional):
  #   - `:expand` [list of binaries, default []]: fields to expand information. ex: ["rules", "security_code", "number", "expiration"]
  #   - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  # ## Return:
  #   - list of CorporateCard objects with updated attributes
  # """
  # @spec create(
  #   [CorporateCard.t() | map],
  #   expand: [binary] | nil,
  #   user: Organization.t() | Project.t() | nil
  # ) ::
  #   {:ok, [CorporateCard.t()]} |
  #   {:error, [Error.t()]}
  # def create(cards, options \\ []) do
  #   Rest.post(
  #     resource(),
  #     cards,
  #     options
  #   )
  # end

  # @doc """
  # Same as create(), but it will unwrap the error tuple and raise in case of errors.
  # """
  # @spec create!(
  #   [CorporateCard.t() | map],
  #   expand: [binary] | nil,
  #   user: Organization.t() | Project.t() | nil
  # ) :: any
  # def create!(cards, options \\ []) do
  #   Rest.post!(
  #     resource(),
  #     cards,
  #     options
  #   )
  # end

  @doc """
  Receive a stream of CorporateCard objects previously created in the Stark Bank API.

  ## Parameters (optional):
    - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["active", "blocked", "canceled", "expired"]
    - `:types` [list of binaries, default nil]: card type. ex: ["virtual"]
    - `:holder_ids` [list of binaries, default nil]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["rules", "security_code", "number", "expiration"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CorporateCard objects with updated attributes
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
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, [CorporateCard.t()]} |
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
    limit: integer,
    after: Date.t() | binary,
    before: Date.t() | binary,
    status: [binary],
    types: [binary],
    holder_ids: [binary],
    ids: [binary],
    tags: [binary],
    expand: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def query!(options \\ []) do
    Rest.get_list!(
      resource(),
      options
    )
  end

  @doc """
  Receive a list of CorporateCard previously created in the Stark Bank API and the cursor to the next page.

  ## Parameters (optional):
    - `:cursor` [binary, default nil]: cursor returned on the previous page function call
    - `:limit` [integer, default 100]: maximum number of objects to be retrieved. It must be an integer between 1 and 100. ex: 50
    - `:after` [Date or binary, default nil]: date filter for objects created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or binary, default nil]: date filter for objects created only before specified date. ex: ~D[2020-03-25]
    - `:status` [list of binaries, default nil]: filter for status of retrieved objects. ex: ["active", "blocked", "canceled", "expired"]
    - `:types` [list of binaries, default nil]: card type. ex: ["virtual"]
    - `:holder_ids` [list of binaries, default nil]: card holder IDs. ex: ["5656565656565656", "4545454545454545"]
    - `:ids` [list of binaries, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    - `:tags` [list of binaries, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["rules", "security_code", "number", "expiration"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of CorporateCard objects with updated attributes
    - cursor to retrieve the next page of CorporateCard objects
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
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, {binary, [CorporateCard.t()]}} |
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
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def page!(options \\ []) do
    Rest.get_page!(
      resource(),
      options
    )
  end

  @doc """
  Receive a single CorporateCard objects previously created in the Stark Bank API by its id.

  ## Parameters (required):
    - `:id` [binary]: object unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:expand` [list of binaries, default nil]: fields to expand information. ex: ["rules", "security_code", "number", "expiration"]
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - CorporateCard objects that corresponds to the given id.
  """
  @spec get(
    id: binary,
    expand: [binary] | nil,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, CorporateCard.t()} |
    {:error, [Error.t()]}
  def get(id, options \\ []) do
    Rest.get_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(
    id: binary,
    expand: [binary] | nil,
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def get!(id, options \\ []) do
    Rest.get_id!(
      resource(),
      id,
      options
    )
  end

  @doc """
  Update a CorporateCard by passing id.

  ## Parameters (required):
    - `:id` [binary]: CorporateCard id. ex: '5656565656565656'

  ## Parameters (Optional):
    - `:status` [binary, default nil]: You may block the CorporateCard by passing 'blocked' or activate by passing 'active' in the status
    - `:display_name` [binary, default nil]: card displayed name. ex: "ANTHONY EDWARD"
    - `:pin` [binary, default nil]: You may unlock your physical card by passing its PIN. This is also the PIN you use to authorize a purhcase.
    - `:rules` [list of dictionaries, default nil]: list of dictionaries with "amount": int, "currencyCode": binary, "id": binary, "interval": binary, "name": binary pairs.
    - `:tags` [list of binaries, default nil]: list of binaries for tagging
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - target CorporateCard with updated attributes
  """
  @spec update(
    id: binary,
    status: binary,
    display_name: binary,
    pin: binary,
    rules: [CorporateRule.t()],
    tags: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, CorporateCard.t()} |
    {:error, [Error.t()]}
  def update(id, parameters \\ []) do
    Rest.patch_id(
      resource(),
      id,
      parameters
    )
  end

  @doc """
  Same as update(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec update!(
    id: binary,
    status: binary,
    display_name: binary,
    pin: binary,
    rules: [CorporateRule.t()],
    tags: [binary],
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def update!(id, parameters \\ []) do
    Rest.patch_id!(
      resource(),
      id,
      parameters
    )
  end

  @doc """
    Cancel an CorporateCard entity previously created in the Stark Bank API.

  ## Parameters (required):
    - `:id` [binary]: CorporateCard unique id. ex: "5656565656565656"

  ## Parameters (optional):
    - `:user` [Organization/Project, default nil]: Organization or Project object returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - canceled CorporateCard object
  """
  @spec cancel(
    id: binary,
    user: (Organization.t() | Project.t() | nil)
  ) ::
    {:ok, CorporateCard.t()} |
    {:error, [Error.t()]}
  def cancel(id, options \\ []) do
    Rest.delete_id(
      resource(),
      id,
      options
    )
  end

  @doc """
  Same as cancel(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec cancel!(
    id: binary,
    user: (Organization.t() | Project.t() | nil)
  ) :: any
  def cancel!(id, options \\ []) do
    Rest.delete_id!(
      resource(),
      id,
      options
    )
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
      rules: json[:rules] |> Enum.map(fn rule -> API.from_api_json(rule, &CorporateRule.resource_maker/1) end),
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
      expiration: json[:expiration],
      updated: json[:updated] |> Check.datetime(),
      created: json[:created] |> Check.datetime()
    }
  end
end
