defmodule Helpers do
  def treat_list(list) when list == nil do
    nil
  end

  def treat_list(list) do
    Enum.join(list, ",")
  end

  def extract_id(id) when is_binary(id) or is_integer(id) do
    id
  end

  def extract_id(struct) do
    struct.id
  end

  defmodule Customer do
    def encode(customer) do
      address = customer.address

      %{
        name: customer.name,
        email: customer.email,
        taxId: customer.tax_id,
        phone: customer.phone,
        tags: customer.tags,
        address: %{
          streetLine1: address.street_line_1,
          streetLine2: address.street_line_2,
          district: address.district,
          city: address.city,
          stateCode: address.state_code,
          zipCode: address.zip_code
        }
      }
    end

    def decode(customer_map) do
      charge_count = customer_map["chargeCount"]
      address = customer_map["address"]

      %CustomerData{
        name: customer_map["name"],
        email: customer_map["email"],
        tax_id: customer_map["taxId"],
        phone: customer_map["phone"],
        id: customer_map["id"],
        charge_count: %ChargeCount{
          overdue: charge_count["overdue"],
          pending: charge_count["pending"]
        },
        address: %AddressData{
          street_line_1: address["streetLine1"],
          street_line_2: address["streetLine2"],
          district: address["district"],
          city: address["city"],
          state_code: address["stateCode"],
          zip_code: address["zipCode"]
        },
        tags: customer_map["tags"]
      }
    end
  end

  defmodule Charge do
    def encode(charge) do
      address = charge.address

      %{
        name: charge.name,
        email: charge.email,
        taxId: charge.tax_id,
        phone: charge.phone,
        tags: charge.tags,
        address: %{
          streetLine1: address.street_line_1,
          streetLine2: address.street_line_2,
          district: address.district,
          city: address.city,
          stateCode: address.state_code,
          zipCode: address.zip_code
        }
      }
    end

    def decode(charge_map) do
      charge_count = charge_map["chargeCount"]
      address = charge_map["address"]

      %CustomerData{
        name: charge_map["name"],
        email: charge_map["email"],
        tax_id: charge_map["taxId"],
        phone: charge_map["phone"],
        id: charge_map["id"],
        charge_count: %ChargeCount{
          overdue: charge_count["overdue"],
          pending: charge_count["pending"]
        },
        address: %AddressData{
          street_line_1: address["streetLine1"],
          street_line_2: address["streetLine2"],
          district: address["district"],
          city: address["city"],
          state_code: address["stateCode"],
          zip_code: address["zipCode"]
        },
        tags: charge_map["tags"]
      }
    end
  end
end
