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
    # :transaction,
    # :transfer,
    # :transfer_log,
    # :utility_payment,
    # :utility_payment_log,
    # :payment_request,
    # :webhook,
    # :event
  ]
)
