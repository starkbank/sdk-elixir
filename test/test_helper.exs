# remove excluded tags to run specific module tests
ExUnit.start(
  exclude: [
    # :balance,
    # :boleto_log,
    # :boleto_payment_log,
    # :boleto_payment,
    # :boleto,
    # :keys,
    # :transaction,
    # :transfer_log,
    # :transfer,
    # :utility_payment_log,
    # :utility_payment,
    # :das_payment_log,
    # :das_payment,
    # :iss_payment_log,
    # :iss_payment,
    # :webhook,
    # :event
  ]
)
