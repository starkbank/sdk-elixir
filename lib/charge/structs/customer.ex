defmodule StarkBank.Charge.Structs.CustomerData do
  @enforce_keys [:name]
  defstruct name: "",
            email: "",
            tax_id: "",
            phone: "",
            id: nil,
            charge_count: %StarkBank.Charge.Structs.ChargeCountData{},
            address: %StarkBank.Charge.Structs.AddressData{},
            tags: []
end
