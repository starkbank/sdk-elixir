defmodule StarkBank.Charge.Structs.AddressData do
  @doc """
  holds charge customer address data
  usually nested in StarkBank.Charge.Structs.Customer

  parameters:
  - street_line_1 [string]: e.g.: "Av. Faria Lima, 1844";
  - street_line_2 [string]: e.g.: "CJ 13";
  - district [string]: e.g.: "Itaim Bibi";
  - city [string]: e.g.: "Sao Paulo";
  - state_code [string]: e.g.: "SP";
  - zip_code [string]: e.g.: "01500-000";
  """
  defstruct street_line_1: "",
            street_line_2: "",
            district: "",
            city: "",
            state_code: "",
            zip_code: ""
end
