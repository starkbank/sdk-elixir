defmodule StarkBank.PaymentPreview do
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.API
  alias StarkBank.PaymentPreview
  alias StarkBank.PaymentPreview.BrcodePreview, as: BrcodePreview
  alias StarkBank.PaymentPreview.BoletoPreview, as: BoletoPreview
  alias StarkBank.PaymentPreview.TaxPreview, as: TaxPreview
  alias StarkBank.PaymentPreview.UtilityPreview, as: UtilityPreview
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups PaymentPreview related functions
  """

  @doc """
  A PaymentPreview is used to get information from a payment code before confirming the payment.
  This resource can be used to preview BR Codes and bar codes of boleto, tax and utility payments

  ## Parameters (required):
    - `:id` [string]: Main identification of the payment. This should be the BR Code for Pix payments and lines or bar codes for payment slips. ex: "34191.09008 63571.277308 71444.640008 5 81960000000062", "00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A"

  ## Parameters (optional):
    - `:scheduled` [Date or string]: intended payment date. Right now, this parameter only has effect on BrcodePreviews. ex: 2020-12-31

  ## Attributes (return-only):
    - `:type` [string]: Payment type. ex: "brcode-payment", "boleto-payment", "utility-payment" or "tax-payment"
    - `:payment` [BrcodePreview, BoletoPreview, UtilityPreview or TaxPreview]: Information preview of the informed payment.
  """
  defstruct [
    :id,
    :scheduled,
    :type,
    :payment
  ]

  @type t() :: %__MODULE__{}


  @doc """
  Send a list of PaymentPreviews objects for processing in the Stark Bank API

  ## Parameters (required):
    - `:previews` [list of PaymentPreviews structs]: list of PaymentPreviews objects to be created in the API

  ## Options:
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - list of PaymentPreviews structs with updated attributes
  """
  @spec create([PaymentPreview.t() | map()], user: Project.t() | Organization.t() | nil) ::
          {:ok, [PaymentPreview.t()]} | {:error, [Error.t()]}
  def create(previews, options \\ []) do
    Rest.post(
      resource(),
      previews,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!([PaymentPreview.t() | map()], user: Project.t() | Organization.t() | nil) :: any
  def create!(previews, options \\ []) do
    Rest.post!(
      resource(),
      previews,
      options
    )
  end

  defp parse_payment!(payment_preview, type) do
    case type do
      "brcode-payment" -> API.from_api_json(payment_preview, &BrcodePreview.resource_maker/1)
      "boleto-payment" -> API.from_api_json(payment_preview, &BoletoPreview.resource_maker/1)
      "utility-payment" -> API.from_api_json(payment_preview, &UtilityPreview.resource_maker/1)
      "tax-payment" -> API.from_api_json(payment_preview, &TaxPreview.resource_maker/1)
      _ -> payment_preview
    end
  end

  @doc false
  def resource() do
    {
      "PaymentPreview",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %PaymentPreview{
      id: json[:id],
      scheduled: json[:scheduled] |> Check.date(),
      type: json[:type],
      payment: parse_payment!(json[:payment], json[:type]),
    }
  end
end
