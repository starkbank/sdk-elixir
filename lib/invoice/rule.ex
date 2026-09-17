defmodule StarkBank.Invoice.Rule do
  alias __MODULE__, as: Rule
  alias StarkBank.Utils.API

  @moduledoc """
  Groups Invoice.Rule related functions
  """

  @doc """
  The Invoice.Rule struct modifies the behavior of Invoice structs when passed as an argument upon their creation.

  ## Parameters (required):
    - `:key` [string]: Rule to be customized, describes what Invoice behavior will be altered. ex: "allowedTaxIds"
    - `:value` [list of strings]: value of the rule. ex: ["012.345.678-90", "45.059.493/0001-73"]
  """
  @enforce_keys [:key, :value]
  defstruct [:key, :value]

  @type t() :: %__MODULE__{}

  @doc false
  def parse_rules(nil), do: nil

  def parse_rules(rules) do
    Enum.map(rules, fn
      %Rule{} = rule -> rule
      rule -> rule |> API.from_api_json(&resource_maker/1)
    end)
  end

  @doc false
  def resource_maker(json) do
    %Rule{
      key: json[:key],
      value: json[:value]
    }
  end
end
