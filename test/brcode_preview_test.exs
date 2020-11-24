defmodule StarkBankTest.BrcodePreview do
  use ExUnit.Case

  @tag :brcode_preview
  test "query brcode preview" do
    invoice = StarkBank.Invoice.query!(
      after: Date.utc_today |> Date.add(-30),
      before: Date.utc_today |> Date.add(-1),
      limit: 1
    ) |> Enum.take(1) |> hd()

    StarkBank.BrcodePreview.query(brcodes: [invoice.brcode])
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 1 end).()
  end

  @tag :brcode_preview
  test "query! brcode preview" do
    invoice = StarkBank.Invoice.query!(
      after: Date.utc_today |> Date.add(-30),
      before: Date.utc_today |> Date.add(-1),
      limit: 1
    ) |> Enum.take(1) |> hd()

    StarkBank.BrcodePreview.query!(brcodes: [invoice.brcode])
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 1 end).()
  end

end
