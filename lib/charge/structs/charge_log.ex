defmodule StarkBank.Charge.Structs.ChargeLogData do
  @doc """
  holds a single charge log data
  usually nested in StarkBank.Charge.Structs.Charge

  parameters:
  - id [string]: charge log id, e.g.: 312387192837;
  - event [string]: log event, namely: "register", "registered", "overdue", "updated", "canceled", "failed", "paid" or "bank";
  - created [timestamp as string]: log creation timestamp, e.g.: "2019-05-21T23:15:50.567533+00:00";
  - errors [list of strings]: list of errors logs;
  - charge [StarkBank.Charge.Structs.Charge]: charge data;
  """
  defstruct [:id, :event, :created, :errors, :charge]
end
