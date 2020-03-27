defmodule StarkBank.Transfer.Data do
  @moduledoc """
  # Transfer struct

  When you initialize a Transfer, the entity will not be automatically
  created in the Stark Bank API. The 'create' function sends the structs
  to the Stark Bank API and returns the list of created structs.

  ## Parameters (required):
    - amount [integer]: amount in cents to be transferred. ex: 1234 (= R$ 12.34)
    - name [string]: receiver full name. ex: "Anthony Edward Stark"
    - tax_id [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: "01234567890" or "20.018.183/0001-80"
    - bank_code [string]: receiver 1 to 3 digits of the bank institution in Brazil. ex: "200" or "341"
    - branch_code [string]: receiver bank account branch. Use '-' in case there is a verifier digit. ex: "1357-9"
    - account_number [string]: Receiver Bank Account number. Use '-' before the verifier digit. ex: "876543-2"

  ## Parameters (optional):
    - tags [list of strings]: list of strings for reference when searching for transfers. ex: ["employees", "monthly"]

  Attributes (return-only):
    - id [string, default nil]: unique id returned when Transfer is created. ex: "5656565656565656"
    - fee [integer, default nil]: fee charged when transfer is created. ex: 200 (= R$ 2.00)
    - status [string, default nil]: current boleto status. ex: "registered" or "paid"
    - transaction_ids [list of strings, default nil]: ledger transaction ids linked to this transfer (if there are two, second is the chargeback). ex: ["19827356981273"]
    - created [DateTime, default nil]: creation datetime for the transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
    - updated [DateTime, default nil]: latest update datetime for the transfer. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:amount, :name, :tax_id, :bank_code, :branch_code, :account_number]
  defstruct [:amount, :name, :tax_id, :bank_code, :branch_code, :account_number, :transaction_ids, :fee, :tags, :status, :id, :created, :updated]
end
