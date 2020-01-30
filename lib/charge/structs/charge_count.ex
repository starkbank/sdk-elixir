defmodule StarkBank.Charge.Structs.ChargeCountData do
  @doc """
  Holds customer charge counters
  Is usually nested in StarkBank.Charge.Structs.Charge

  Parameters:
  - overdue [int]: counts the customer overdue charges, e.g.: 3;
  - pending [int]: counts the customer pending charges, e.g.: 2;
  """
  defstruct overdue: nil,
            pending: nil
end
