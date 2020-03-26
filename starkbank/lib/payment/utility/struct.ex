defmodule StarkBank.Payment.Utility.Data do
  @moduledoc """
  UtilityPayment struct

  When you initialize a UtilityPayment, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  Parameters (conditionally required):
    line [string, default nil]: Number sequence that describes the payment. Either 'line' or 'bar_code' parameters are required. If both are sent, they must match. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    bar_code [string, default nil]: Bar code number that describes the payment. Either 'line' or 'barCode' parameters are required. If both are sent, they must match. ex: "34195819600000000621090063571277307144464000"
  Parameters (required):
    description [string]: Text to be displayed in your statement (min. 10 characters). ex: "payment ABC"
  Parameters (optional):
    scheduled [Date, default today]: payment scheduled date. ex: ~D[2020-03-25]
    tags [list of strings]: list of strings for tagging
  Attributes (return-only):
    id [string, default nil]: unique id returned when payment is created. ex: "5656565656565656"
    status [string, default nil]: current payment status. ex: "registered" or "paid"
    amount [int, default nil]: amount automatically calculated from line or bar_code. ex: 23456 (= R$ 234.56)
    created [DateTime, default nil]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:description]
  defstruct [:line, :bar_code, :description, :scheduled, :tags, :id, :status, :amount, :created]
end
