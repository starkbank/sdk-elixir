defmodule StarkBank.BrcodePayment.Rule do
  alias __MODULE__, as: Rule

  @moduledoc """
  Groups Rule related functions
  """

  @doc """
  The BrcodePayment.Rule object modifies the behavior of BrcodePayment objects when passed as an argument upon their creation.

  ## Parameters (required):
    - `:key` [int]: Rule to be customized, describes what BrcodePayment behavior will be altered. ex: "resendingLimit"
    - `:value` [string]: Value of the rule. ex: 5
  """
  @enforce_keys [
    :key,
    :value
  ]
  defstruct [
    :key,
    :value
  ]

  @type t() :: %__MODULE__{}

      @doc false
      def resource() do
        {
          "Rule",
          &resource_maker/1
        }
      end

      @doc false
      def resource_maker(json) do
        %Rule{
          key: json[:key],
          value: json[:value]
        }
      end
    end
