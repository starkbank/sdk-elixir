defmodule StarkBank.CorporateRule do
  alias StarkBank.CardMethod
  alias StarkBank.MerchantCountry
  alias StarkBank.MerchantCategory
  alias StarkBank.Utils.API
  alias __MODULE__, as: CorporateRule

  @moduledoc """
    # CorporateRule object
  """

  @doc """
  The CorporateRule object displays the spending rules of CorporateCards and CorporateHolders created in your Workspace.

  ## Parameters (required):
    - `:name` [binary]: rule name. ex: "Travel" or "Food"
    - `:amount` [integer]: maximum amount that can be spent in the informed interval. ex: 200000 (= R$ 2000.00)

    ## Parameters (optional):
    - `:interval` [binary, default nil]: interval after which the rule amount counter will be reset to 0. ex: "instant", "day", "week", "month", "year" or "lifetime"
    - `:schedule` [string, default nil]: schedule time for user to spend. ex: "every monday, wednesday from 00:00 to 23:59 in America/Sao_Paulo"
    - `:purposes` [list of string, default []]: list of strings representing the allowed purposes for card purchases, you can use this to restrict ATM withdrawals. ex: ["purchase", "withdrawal"]
    - `:currency_code` [binary, default "BRL"]: code of the currency that the rule amount refers to. ex: "BRL" or "USD"
    - `:categories` [list of MerchantCategories, default []]: merchant categories accepted by the rule. ex: [%{ code: "fastFoodRestaurants"}]
    - `:countries` [list of MerchantCountries, default []]: countries accepted by the rule. ex: [%{ code: "BRA"}]
    - `:methods` [list of CardMethods, default []]: card purchase methods accepted by the rule. ex: [%{ code: "magstripe"}]

    ## Attributes (expanded return-only):
    - `:id` [binary]: unique id returned when Rule is created, used to update a specific CorporateRule. ex: "5656565656565656"
    - `:counter_amount` [integer]: current rule spent amount. ex: 1000
    - `:currency_symbol` [binary]: currency symbol. ex: "R$"
    - `:currency_name` [binary]: currency name. ex: "Brazilian Real"
  """
  @enforce_keys [
    :name,
    :amount
  ]
  defstruct [
    :id,
    :name,
    :amount,
    :interval,
    :schedule,
    :purposes,
    :currency_code,
    :categories,
    :countries,
    :methods,
    :counter_amount,
    :currency_symbol,
    :currency_name
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource() do
    {
      "CorporateRule",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CorporateRule{
      amount: json[:amount],
      currency_code: json[:currency_code],
      id: json[:id],
      interval: json[:interval],
      schedule: json[:schedule],
      purposes: json[:purposes],
      name: json[:name],
      categories: json[:categories] |> Enum.map(fn category -> API.from_api_json(category, &MerchantCategory.resource_maker/1) end),
      countries: json[:countries] |> Enum.map(fn country -> API.from_api_json(country, &MerchantCountry.resource_maker/1) end),
      methods: json[:methods] |> Enum.map(fn method -> API.from_api_json(method, &CardMethod.resource_maker/1) end),
      counter_amount: json[:counter_amount],
      currency_symbol: json[:currency_symbol],
      currency_name: json[:currency_name]
    }
  end
end
