defmodule StarkBank.Payment.Boleto.Log.Data do
  @moduledoc """
  BoletoPaymentLog struct

  Every time a BoletoPayment entity is modified, a corresponding BoletoPaymentLog
  is generated for the entity. This log is never generated by the
  user, but it can be retrieved to check additional information
  on the BoletoPayment.

  Attributes:
    id [string]: unique id returned when the log is created. ex: "5656565656565656"
    payment [BoletoPayment]: BoletoPayment entity to which the log refers to.
    errors [list of strings]: list of errors linked to this BoletoPayment event.
    type [string]: type of the BoletoPayment event which triggered the log creation. ex: "registered" or "paid"
    created [DateTime]: creation datetime for the payment. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :payment, :errors, :type, :created]
  defstruct [:id, :payment, :errors, :type, :created]
end
