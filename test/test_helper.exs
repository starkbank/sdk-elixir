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
    # :webhook,
    # :event
  ]
)

defmodule StarkBankTest.Credentials do
  @project_id "5690398416568320"
  @private_key """
  -----BEGIN EC PARAMETERS-----
  BgUrgQQACg==
  -----END EC PARAMETERS-----
  -----BEGIN EC PRIVATE KEY-----
  MHQCAQEEIIoYWZ2OGwqX6n1EVvj1C1YvWHSGqqhZJzfsZZnk0SVgoAcGBSuBBAAK
  oUQDQgAEGS1jWJXoK9RUk+qoNNFquO7X4JzRf5ZA5UDJUfPCbbKe5KwtrBKTJC1/
  vRGIpAM5gNsxdfKgmoXNriiuY4LEPQ==
  -----END EC PRIVATE KEY-----
  """

  def project() do
    StarkBank.project(:sandbox, @project_id, @private_key)
  end
end
