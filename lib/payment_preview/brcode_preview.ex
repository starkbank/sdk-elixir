defmodule StarkBank.PaymentPreview.BrcodePreview do
    alias StarkBank.PaymentPreview.BrcodePreview

    @moduledoc """
    Groups BrcodePreview related functions
    """

    @doc """
    A BrcodePreview is used to get information from a BR Code you received before confirming the payment.

    ## Attributes (return-only):
      - `:status` [string]: Payment status. ex: "active", "paid", "canceled" or "unknown"
      - `:name` [string]: Payment receiver name. ex: "Tony Stark"
      - `:tax_id` [string]: Payment receiver tax ID. ex: "012.345.678-90"
      - `:bank_code` [string]: Payment receiver bank code. ex: "20018183"
      - `:account_type` [string]: Payment receiver account type. ex: "checking"
      - `:allow_change` [bool]: If True, the payment is able to receive amounts that are different from the nominal one. ex: True or False
      - `:amount` [integer]: Value in cents that this payment is expecting to receive. If 0, any value is accepted. ex: 123 (= R$1,23)
      - `:nominal_amount` [integer]: Original value in cents that this payment was expecting to receive without the discounts, fines, etc.. If 0, any value is accepted. ex: 123 (= R$1,23)
      - `:interest_amount` [integer]: Current interest value in cents that this payment is charging. If 0, any value is accepted. ex: 123 (= R$1,23)
      - `:fine_amount` [integer]: Current fine value in cents that this payment is charging. ex: 123 (= R$1,23)
      - `:reduction_amount` [integer]: Current value reduction value in cents that this payment is expecting. ex: 123 (= R$1,23)
      - `:discount_amount` [integer]: Current discount value in cents that this payment is expecting. ex: 123 (= R$1,23)
      - `:reconciliation_id` [string]: Reconciliation ID linked to this payment. ex: "txId", "payment-123"
    """
    defstruct [
      :status,
      :name,
      :tax_id,
      :bank_code,
      :account_type,
      :allow_change,
      :amount,
      :nominal_amount,
      :interest_amount,
      :fine_amount,
      :reduction_amount,
      :discount_amount,
      :reconciliation_id
    ]

    @type t() :: %__MODULE__{}

    @doc false
    def resource() do
      {
        "BrcodePreview",
        &resource_maker/1
      }
    end

    @doc false
    def resource_maker(json) do
      # IO.inspect json
      %BrcodePreview{
        status: json[:status],
        name: json[:name],
        tax_id: json[:tax_id],
        bank_code: json[:bank_code],
        account_type: json[:account_type],
        allow_change: json[:allow_change],
        amount: json[:amount],
        nominal_amount: json[:nominal_amount],
        interest_amount: json[:interest_amount],
        fine_amount: json[:fine_amount],
        reduction_amount: json[:reduction_amount],
        discount_amount: json[:discount_amount],
        reconciliation_id: json[:reconciliation_id],
      }
    end
  end
