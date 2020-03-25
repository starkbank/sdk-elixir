defmodule StarkBank.Key do

  @moduledoc """
  Used to generate API-compatible key pairs
  """

  alias EllipticCurve.PrivateKey, as: PrivateKey
  alias EllipticCurve.PublicKey, as: PublicKey

  @doc """
  Generates a secp256k1 ECDSA private/public key pair to be used in the API authentications

  Parameters (optional):
      path [string]: path to save the keys .pem files. No files will be saved if this parameter isn't provided
  """
  @spec create(any) :: {binary, binary}
  def create(path \\ nil) do
    private = PrivateKey.generate()
    public = PrivateKey.getPublicKey(private)

    private_pem = private |> PrivateKey.toPem()
    public_pem = public |> PublicKey.toPem()

    save_file(private_pem, path, "privateKey.pem")
    save_file(public_pem, path, "publicKey.pem")

    {private_pem, public_pem}
  end

  defp save_file(_pem, path, _suffix) when is_nil(path) do
  end

  defp save_file(pem, path, suffix) do
    File.mkdir_p!(path)
    file = File.open!(Path.join(path,  suffix), [:write])
    IO.binwrite(file, pem)
    File.close(file)
  end
end
