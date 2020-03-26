defmodule StarkBank.Webhook.Data do
  @moduledoc """
  Webhook subscription struct

  A Webhook is used to subscribe to notification events on a user-selected endpoint.
  Currently available services for subscription are transfer, boleto, boleto-payment,
  and utility-payment

  Parameters (required):
    url [string]: Url that will be notified when an event occurs.
    subscriptions [list of strings]: list of any non-empty combination of the available services. ex: ["transfer", "boleto-payment"]
  Attributes:
    id [string, default nil]: unique id returned when the log is created. ex: "5656565656565656"
  """
  @enforce_keys [:url, :subscriptions]
  defstruct [:id, :url, :subscriptions]
end
