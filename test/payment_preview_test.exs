defmodule StarkBankTest.PaymentPreview do
  use ExUnit.Case

  @tag :payment_preview
  test "create! PaymentPreview" do
    previews = StarkBank.PaymentPreview.create!(generate_preview_ids())
    for preview <- previews do
      assert !is_nil(preview.id)
    end
  end

  @tag :payment_preview
  test "create PaymentPreview" do
    {:ok, previews} = StarkBank.PaymentPreview.create(generate_preview_ids())
    for preview <- previews do
      assert !is_nil(preview.id)
    end
  end

  defp generate_preview_ids() do
    [
      %StarkBank.PaymentPreview{ scheduled: Date.utc_today() |> Date.add(2), id: StarkBankTest.BrcodePayment.example_payment(false).brcode },
      %StarkBank.PaymentPreview{ id: StarkBankTest.BoletoPayment.example_payment(false).line },
      %StarkBank.PaymentPreview{ id: StarkBankTest.TaxPayment.example_payment(false).bar_code },
      %StarkBank.PaymentPreview{ id: StarkBankTest.UtilityPayment.example_payment(false).bar_code }
    ]
  end
end
