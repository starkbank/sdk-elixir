defmodule StarkBank.Charge.Structs.ChargeCountData do
  @doc """
  holds a customer charge counters
  usually nested in StarkBank.Charge.Structs.Charge

  parameters:
  - overdue [int]: counts the customer overdue charges, e.g.: 3;
  - pending [int]: counts the customer pending charges, e.g.: 2;
  """
  defstruct overdue: nil,
            pending: nil
end
