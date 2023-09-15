defmodule StarkBank.Invoice.Payment do
  alias StarkBank.Invoice

  @moduledoc """
  Groups Invoice.Payment related functions
  """

  @doc """
  When an Invoice is paid, its Payment sub-resource will become available.
  It carries all the available information about the invoice payment.

  ## Attributes:
    - `:amount` [integer]: amount in cents that was paid. ex: 1234 (= R$ 12.34)
    - `:name` [string]: payer full name. ex: "Anthony Edward Stark"
    - `:tax_id` [string]: payer tax ID (CPF or CNPJ). ex: "20.018.183/0001-80"
    - `:bank_code` [string]: code of the payer bank institution in Brazil. ex: "20018183"
    - `:branch_code` [string]: payer bank account branch. ex: "1357-9"
    - `:account_number` [string]: payer bank account number. ex: "876543-2"
    - `:account_type` [string]: payer bank account type. ex: "checking", "savings", "salary" or "payment"
    - `:end_to_end_id` [string]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
    - `:method` [string]: payment method that was used. ex: "pix"
  """
  defstruct [
    :name,
    :tax_id,
    :bank_code,
    :branch_code,
    :account_number,
    :account_type,
    :amount,
    :end_to_end_id,
    :method
  ]

  @type t() :: %__MODULE__{}

  def resource() do
    {
      "Payment",
      &resource_maker/1
    }
  end

  def resource_maker(json) do
    %Invoice.Payment{
      name: json[:name],
      tax_id: json[:tax_id],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      account_number: json[:account_number],
      account_type: json[:account_type],
      amount: json[:amount],
      end_to_end_id: json[:end_to_end_id],
      method: json[:method]
    }
  end
end
