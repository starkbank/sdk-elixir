defmodule StarkBank.Boleto.Data do
  @moduledoc """
  Boleto struct

  When you initialize a Boleto, the entity will not be automatically
  sent to the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  Parameters (required):
    amount [integer]: Boleto value in cents. ex: 1234 (= R$ 12.34)
    name [string]: payer full name. ex: "Anthony Edward Stark"
    tax_id [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    street_line_1 [string]: payer main address. ex: Av. Paulista, 200
    street_line_2 [string]: payer address complement. ex: Apto. 123
    district [string]: payer address district / neighbourhood. ex: Bela Vista
    city [string]: payer address city. ex: Rio de Janeiro
    state_code [string]: payer address state. ex: GO
    zip_code [string]: payer address zip code. ex: 01311-200
    due [Date, default today + 2 days]: Boleto due date in ISO format. ex: 2020-04-30
  Parameters (optional):
    fine [float, default 0.0]: Boleto fine for overdue payment in %. ex: 2.5
    interest [float, default 0.0]: Boleto monthly interest for overdue payment in %. ex: 5.2
    overdue_limit [integer, default 59]: limit in days for automatic Boleto cancellation after due date. ex: 7 (max: 59)
    descriptions [list of maps, default nil]: list of maps with :text (string) and :amount (int, optional) pairs
    tags [list of strings]: list of strings for tagging
  Attributes (return-only):
    id [string, default nil]: unique id returned when Boleto is created. ex: "5656565656565656"
    fee [integer, default nil]: fee charged when Boleto is paid. ex: 200 (= R$ 2.00)
    line [string, default nil]: generated Boleto line for payment. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062"
    bar_code [string, default nil]: generated Boleto bar-code for payment. ex: "34195819600000000621090063571277307144464000"
    status [string, default nil]: current Boleto status. ex: "registered" or "paid"
    created [DateTime, default nil]: creation datetime for the Boleto. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:amount, :name, :tax_id, :street_line_1, :street_line_2, :district, :city, :state_code, :zip_code]
  defstruct [:amount, :name, :tax_id, :street_line_1, :street_line_2, :district, :city, :state_code, :zip_code, :due, :fine, :interest, :overdue_limit, :tags, :descriptions, :id, :fee, :line, :bar_code, :status, :created]
end
