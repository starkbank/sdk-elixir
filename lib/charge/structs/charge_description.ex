defmodule StarkBank.Charge.Structs.ChargeDescriptionData do
  @doc """
  Holds data from a single charge description
  Is usually nested in StarkBank.Charge.Structs.Charge

  Parameters:
  - text [string]: text describing the apointed amount, e.g.: "- Taxes";
  - amount [int]: part of the charge total amount (in cents) that is being described, e.g.: 579;
  """
  defstruct [:text, :amount]
end
