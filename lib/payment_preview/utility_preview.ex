defmodule StarkBank.PaymentPreview.UtilityPreview do
    alias StarkBank.Utils.Rest
    alias StarkBank.PaymentPreview.UtilityPreview
    alias StarkBank.User.Project
    alias StarkBank.User.Organization
    alias StarkBank.Error
  
    @moduledoc """
    Groups UtilityPreview related functions
    """
  
    @doc """
    A UtilityPreview is used to get information from a BR Code
    you received to check the informations before paying it.
  
    ## Attributes (return-only):
      - `:amount` [int]: final amount to be paid. ex: 23456 (= R$ 234.56)
      - `:name` [string]: beneficiary full name. ex: "Light Company"
      - `:description` [string]: utility payment description. ex: "Utility Payment - Light Company"
      - `:line` [string]: Number sequence that identifies the payment. ex: "82660000002 8 44361143007 7 41190025511 7 00010601813 8"
      - `:bar_code` [string]: Bar code number that identifies the payment. ex: "82660000002443611430074119002551100010601813"
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
        "UtilityPreview",
        &resource_maker/1
      }
    end
  
    @doc false
    def resource_maker(json) do
      %UtilityPreview{
        amount: json[:amount],
        name: json[:name],
        description: json[:description],
        line: json[:line],
        bar_code: json[:bar_code]
      }
    end
  end
  