defmodule StarkBank.MerchantSession.AllowedInstallment do
  alias __MODULE__, as: AllowedInstallment

  @moduledoc """
  Groups MerchantSession.AllowedInstallment related functions
  """

  @doc """
  AllowedInstallment represents an amount/installment-count combination allowed for a MerchantSession purchase.

  ## Parameters (required):
    - `:total_amount` [integer]: total purchase amount in cents allowed for this installment plan. ex: 5000 (= R$ 50.00)
    - `:count` [integer]: number of installments allowed for this total_amount. ex: 1
  """
  @enforce_keys [:total_amount, :count]
  defstruct [:total_amount, :count]

  @type t() :: %__MODULE__{}

  @doc false
  def resource_maker(json) do
    %AllowedInstallment{
      total_amount: json[:total_amount],
      count: json[:count]
    }
  end
end
