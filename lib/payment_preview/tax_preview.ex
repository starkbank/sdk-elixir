defmodule StarkBank.PaymentPreview.TaxPreview do
    alias StarkBank.Utils.Rest
    alias StarkBank.PaymentPreview.TaxPreview
    alias StarkBank.User.Project
    alias StarkBank.User.Organization
    alias StarkBank.Error
  
    @moduledoc """
    Groups TaxPreview related functions
    """
  
    @doc """
    A TaxPreview is used to get information from a Tax Payment you received before confirming the payment.
  
    ## Attributes (return-only):
      - `:amount` [int]: final amount to be paid. ex: 23456 (= R$ 234.56)
      - `:name` [string]: beneficiary full name. ex: "Iron Throne"
      - `:description` [string]: tax payment description. ex: "ISS Payment - Iron Throne"
      - `:line` [string]: Number sequence that identifies the payment. ex: "85660000006 6 67940064007 5 41190025511 7 00010601813 8"
      - `:bar_code` [string]: Bar code number that identifies the payment. ex: "85660000006679400640074119002551100010601813"
    """
    defstruct [
      :amount,
      :name,
      :description,
      :line,
      :bar_code
    ]
  
    @type t() :: %__MODULE__{}
    
    @doc false
    def resource() do
      {
        "TaxPreview",
        &resource_maker/1
      }
    end
  
    @doc false
    def resource_maker(json) do
      %TaxPreview{
        amount: json[:amount],
        name: json[:name],
        description: json[:description],
        line: json[:line],
        bar_code: json[:bar_code]
      }
    end
  end
  