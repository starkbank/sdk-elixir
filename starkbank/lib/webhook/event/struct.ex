defmodule StarkBank.Webhook.Event.Data do
  @moduledoc """
  Webhook Event struct

  An Event is the notification received from the subscription to the Webhook.
  Events cannot be created, but may be retrieved from the Stark Bank API to
  list all generated updates on entities.

  Attributes:
    id [string]: unique id returned when the log is created. ex: "5656565656565656"
    log [Log]: a Log struct from one the subscription services (TransferLog, BoletoLog, BoletoPaymentlog or UtilityPaymentLog)
    created [DateTime]: creation datetime for the notification event. ex: ~U[2020-03-26 19:32:35.418698Z]
    delivered [DateTime]: delivery datetime when the notification was delivered to the user url. Will be nil if no successful attempts to deliver the event occurred. ex: ~U[2020-03-26 19:32:35.418698Z]
    subscription [string]: service that triggered this event. ex: "transfer", "utility-payment"
  """
  defstruct [:id, :log, :created, :delivered, :subscription]
end
