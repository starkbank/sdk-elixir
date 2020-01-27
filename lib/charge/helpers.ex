defmodule StarkBank.Charge.Helpers do
  alias StarkBank.Utils.Helpers, as: MainHelpers

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

      %StarkBank.Charge.Structs.CustomerData{
        name: customer_map["name"],
        email: customer_map["email"],
        tax_id: customer_map["taxId"],
        phone: customer_map["phone"],
        id: customer_map["id"],
        charge_count: %StarkBank.Charge.Structs.ChargeCountData{
          overdue: charge_count["overdue"],
          pending: charge_count["pending"]
        },
        address: %StarkBank.Charge.Structs.AddressData{
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
      %{
        amount: charge.amount,
        customerId: MainHelpers.extract_id(charge.customer),
        dueDate: MainHelpers.date_to_string(charge.due_date),
        fine: charge.fine,
        interest: charge.interest,
        overdueLimit: charge.overdue_limit,
        tags: charge.tags,
        descriptions: for(description <- charge.descriptions, do: encode_description(description))
      }
    end

    def decode(charge_map) do
      %StarkBank.Charge.Structs.ChargeData{
        amount: charge_map["amount"],
        id: charge_map["id"],
        bar_code: charge_map["barCode"],
        line: charge_map["line"],
        due_date: charge_map["dueDate"],
        fine: charge_map["fine"],
        interest: charge_map["interest"],
        overdue_limit: charge_map["overdueLimit"],
        tags: charge_map["tags"],
        descriptions: decode_descriptions(charge_map["descriptions"]),
        customer: %StarkBank.Charge.Structs.CustomerData{
          name: charge_map["name"],
          tax_id: charge_map["taxId"],
          id: charge_map["customerId"],
          address: %StarkBank.Charge.Structs.AddressData{
            street_line_1: charge_map["streetLine1"],
            street_line_2: charge_map["streetLine2"],
            district: charge_map["district"],
            city: charge_map["city"],
            state_code: charge_map["stateCode"],
            zip_code: charge_map["zipCode"]
          }
        }
      }
    end

    defp encode_description(description) do
      %{text: description.text, amount: description.amount}
    end

    defp decode_descriptions(descriptions) when is_nil(descriptions) do
      []
    end

    defp decode_descriptions(descriptions) do
      for description_map <- descriptions, do: decode_description(description_map)
    end

    defp decode_description(description) do
      %StarkBank.Charge.Structs.ChargeDescriptionData{
        text: description["text"],
        amount: description["amount"]
      }
    end
  end

  defmodule ChargeLog do
    def decode(charge_log_map) do
      %StarkBank.Charge.Structs.ChargeLogData{
        id: charge_log_map["id"],
        event: charge_log_map["event"],
        created: charge_log_map["created"],
        errors: charge_log_map["errors"],
        charge: Charge.decode(charge_log_map["charge"])
      }
    end
  end
end
