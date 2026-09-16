defmodule StarkBank.CorporateRule do
  alias __MODULE__, as: CorporateRule
  alias StarkBank.Utils.API
  alias StarkBank.CardMethod
  alias StarkBank.MerchantCategory
  alias StarkBank.MerchantCountry

  @moduledoc """
  Groups CorporateRule related functions
  """

  @doc """
  The CorporateRule struct displays the spending rules of CorporateCards and CorporateHolders
  created in your Workspace.

  ## Parameters (required):
    - `:name` [string]: rule name. ex: "Travel" or "Food"
    - `:amount` [integer]: maximum amount that can be spent in the informed interval. ex: 200000 (= R$ 2000.00)

  ## Parameters (optional):
    - `:interval` [string, default "lifetime"]: interval after which the rule amount counter will be reset to 0. ex: "instant", "day", "week", "month", "year" or "lifetime"
    - `:schedule` [string, default nil]: schedule time for user to spend. ex: "every monday, wednesday from 00:00 to 23:59 in America/Sao_Paulo"
    - `:purposes` [list of strings, default []]: list of strings representing the allowed purposes for card purchases, you can use this to restrict ATM withdrawals. ex: ["purchase", "withdrawal"]
    - `:currency_code` [string, default "BRL"]: code of the currency that the rule amount refers to. ex: "BRL" or "USD"
    - `:categories` [list of MerchantCategory structs, default []]: merchant categories accepted by the rule. ex: [%StarkBank.MerchantCategory{code: "fastFoodRestaurants"}]
    - `:countries` [list of MerchantCountry structs, default []]: countries accepted by the rule. ex: [%StarkBank.MerchantCountry{code: "BRA"}]
    - `:methods` [list of CardMethod structs, default []]: card purchase methods accepted by the rule. ex: [%StarkBank.CardMethod{code: "magstripe"}]

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when a CorporateRule is created, used to update a specific CorporateRule. ex: "5656565656565656"
    - `:counter_amount` [integer, default nil]: current rule spent amount. ex: 1000
    - `:currency_symbol` [string, default nil]: currency symbol. ex: "R$"
    - `:currency_name` [string, default nil]: currency name. ex: "Brazilian Real"
  """
  @enforce_keys [:name, :amount]
  defstruct [
    :name,
    :amount,
    :interval,
    :schedule,
    :purposes,
    :currency_code,
    :categories,
    :countries,
    :methods,
    :id,
    :counter_amount,
    :currency_symbol,
    :currency_name
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def parse_rules(nil), do: nil

  def parse_rules(rules) do
    Enum.map(rules, fn
      %CorporateRule{} = rule -> rule
      rule -> rule |> API.from_api_json(&resource_maker/1)
    end)
  end

  @doc false
  def resource_maker(json) do
    %CorporateRule{
      name: json[:name],
      amount: json[:amount],
      interval: json[:interval],
      schedule: json[:schedule],
      purposes: json[:purposes],
      currency_code: json[:currency_code],
      categories: json[:categories] |> parse_categories(),
      countries: json[:countries] |> parse_countries(),
      methods: json[:methods] |> parse_methods(),
      id: json[:id],
      counter_amount: json[:counter_amount],
      currency_symbol: json[:currency_symbol],
      currency_name: json[:currency_name]
    }
  end

  defp parse_categories(nil), do: []

  defp parse_categories(categories) do
    Enum.map(categories, fn category ->
      category |> API.from_api_json(&MerchantCategory.resource_maker/1)
    end)
  end

  defp parse_countries(nil), do: []

  defp parse_countries(countries) do
    Enum.map(countries, fn country ->
      country |> API.from_api_json(&MerchantCountry.resource_maker/1)
    end)
  end

  defp parse_methods(nil), do: []

  defp parse_methods(methods) do
    Enum.map(methods, fn method ->
      method |> API.from_api_json(&CardMethod.resource_maker/1)
    end)
  end
end
