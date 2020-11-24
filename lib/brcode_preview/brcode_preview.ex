defmodule StarkBank.BrcodePreview do
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.BrcodePreview
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups BrcodePreview related functions
  """

  @doc """
  A BrcodePreview is used to get information from a BR Code
  you received to check the informations before paying it.

  ## Attributes (return-only):
    - `:id` [string]: Payment BR Code.
    - `:status` [string]: Payment status. ex: "active", "paid", "canceled" or "unknown"
    - `:name` [string]: Payment receiver name. ex: "Tony Stark"
    - `:tax_id` [string]: Payment receiver tax ID. ex: "012.345.678-90"
    - `:bank_code` [string]: Payment receiver bank code. ex: "20018183"
    - `:branch_code` [string]: Payment receiver branch code. ex: "0001"
    - `:account_number` [string]: Payment receiver account number. ex: "1234567"
    - `:account_type` [string]: Payment receiver account type. ex: "checking"
    - `:allow_change` [bool]: If True, the payment is able to receive amounts that are diferent from the nominal one. ex: True
    - `:amount` [int]: Value in cents that this payment is expecting to receive. If 0, any value is accepted. ex: 123 (= R$1,23)
    - `:reconciliation_id` [string]: Reconciliation ID linked to this payment. ex: "tx_id", "payment123"
  """
  defstruct [
    :id,
    :status,
    :name,
    :tax_id,
    :bank_code,
    :branch_code,
    :account_number,
    :account_type,
    :allow_change,
    :amount,
    :reconciliation_id
  ]

  @type t() :: %__MODULE__{}


  @doc """
  Receive a generator of BrcodePreview objects previously created in the Stark Bank API

  ## Options:
    - `:brcodes` [list of strings, default nil]: List of brcodes to preview. ex: ["00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A"]
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of BrcodePreview structs with updated attributes
  """
  @spec query(
          brcodes: [binary],
          user: Project.t()
        ) ::
          ({:cont, {:ok, [BrcodePreview.t()]}}
           | {:error, [Error.t()]}
           | {:halt, any}
           | {:suspend, any},
           any ->
             any)
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
          brcodes: [binary],
          user: Project.t()
        ) ::
          ({:cont, [BrcodePreview.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "BrcodePreview",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %BrcodePreview{
      id: json[:id],
      status: json[:status],
      name: json[:name],
      tax_id: json[:tax_id],
      bank_code: json[:bank_code],
      branch_code: json[:branch_code],
      account_number: json[:account_number],
      account_type: json[:account_type],
      allow_change: json[:allow_change],
      amount: json[:amount],
      reconciliation_id: json[:reconciliation_id],
    }
  end
end
