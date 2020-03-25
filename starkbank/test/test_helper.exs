ExUnit.start(exclude: [:exclude])  # remove argument to run all tests or comment tag to run specific tags


defmodule StarkBankTest.Credentials do

  @project_id "9999999999999999"
  @private_key "-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEIBEcEJZLk/DyuXVsEjz0w4vrE7plPXhQxODvcG1Jc0WToAcGBSuBBAAK\noUQDQgAE6t4OGx1XYktOzH/7HV6FBukxq0Xs2As6oeN6re1Ttso2fwrh5BJXDq75\nmSYHeclthCRgU8zl6H1lFQ4BKZ5RCQ==\n-----END EC PRIVATE KEY-----\n"

  def project() do
    StarkBank.User.project(:sandbox, @project_id, @private_key)
  end
end
