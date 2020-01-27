defmodule StarkBank.Charge.Structs.ChargeDescriptionData do
  @doc """
  holds a single charge description data
  usually nested in StarkBank.Charge.Structs.Charge

  params:
  - text [string]: text describing the apointed amount, e.g.: "- Taxes";
  - amount [int]: part of the charge total amount (in cents) that is being described, e.g.: 579;
  """
  defstruct [:text, :amount]
end
