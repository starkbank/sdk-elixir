# remove excluded tags to run specific module tests
ExUnit.start(
  exclude: [
    # :keys,
    # :balance,
    # :boleto,
    # :boleto_log,
    # :boleto_payment,
    # :boleto_payment_log,
    # :boleto_holmes,
    # :boleto_holmes_log,
    # :invoice,
    # :invoice_log,
    # :dict_key,
    # :deposit,
    # :deposit_log,
    # :brcode_payment,
    # :brcode_payment_log,
    # :brcode_preview,
    # :transaction,
    # :transfer,
    # :transfer_log,
    # :utility_payment,
    # :utility_payment_log,
    # :tax_payment,
    # :tax_payment_log,
    # :payment_request,
    # :institution,
    # :webhook,
    # :event,
    # :workspace,
  ]
)

Code.require_file("./test/utils/page.exs")
