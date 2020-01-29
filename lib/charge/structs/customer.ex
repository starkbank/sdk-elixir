defmodule StarkBank.Charge.Structs.CustomerData do
  @doc """
  Holds data from a single customer
  Can be nested in StarkBank.Charge.Structs.Charge

  Parameters:
  - name [string]: customer name, e.g.: "Arya Stark";
  - email [string]: customer email, e.g.: "arya.stark@westeros.com";
  - tax_id [string]: customer tax ID (CPF, CNPJ), e.g.: "012.345.678-90";
  - phone [string] customer phone number, e.g.: "(11) 98300-0000";
  - tags [list of strings]: customer custom tags, e.g.: ["little girl", "no one", "valar morghulis", "Stark"];
  - address [StarkBank.Charge.Structs.AddressData]: customer adress data;
  """
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
