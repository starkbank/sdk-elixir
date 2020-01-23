defmodule CustomerData do
  @enforce_keys [:name]
  defstruct name: "",
            email: "",
            tax_id: "",
            phone: "",
            id: nil,
            charge_count: %ChargeCount{},
            address: %AddressData{},
            tags: []
end
