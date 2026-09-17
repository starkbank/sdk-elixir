defmodule StarkBank.BrcodePayment.Rule do
  alias __MODULE__, as: Rule
  alias StarkBank.Utils.API

  @moduledoc """
  Groups BrcodePayment.Rule related functions
  """

  @doc """
  The BrcodePayment.Rule struct modifies the behavior of BrcodePayment structs when passed as an argument upon their creation.

  ## Parameters (required):
    - `:key` [string]: Rule to be customized, describes what BrcodePayment behavior will be altered. ex: "resendingLimit"
    - `:value` [integer]: value of the rule. ex: 5
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
