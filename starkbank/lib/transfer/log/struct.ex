defmodule StarkBank.Transfer.Log.Data do
  @moduledoc """
  # TransferLog struct

  Every time a Transfer entity is modified, a corresponding TransferLog
  is generated for the entity. This log is never generated by the
  user.

  ## Attributes:
    - id [string]: unique id returned when the log is created. ex: "5656565656565656"
    - transfer [Transfer]: Transfer entity to which the log refers to.
    - errors [list of strings]: list of errors linked to this BoletoPayment event.
    - type [string]: type of the Transfer event which triggered the log creation. ex: "processing" or "success"
    - created [DateTime]: creation datetime for the transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :transfer, :errors, :type, :created]
  defstruct [:id, :transfer, :errors, :type, :created]
end
