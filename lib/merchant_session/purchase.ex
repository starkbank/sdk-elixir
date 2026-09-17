defmodule StarkBank.MerchantSession.Purchase do
  alias __MODULE__, as: Purchase
  alias StarkBank.Utils.Check

  @moduledoc """
  Groups MerchantSession.Purchase related functions
  """

  @doc """
  A MerchantSession.Purchase is created against a previously created MerchantSession, identified by its uuid,
  through StarkBank.MerchantSession.purchase/3. Depending on the MerchantSession's allowed_funding_types and
  3DS configuration, the billing and card holder fields (card_expiration, card_number, card_security_code,
  holder_name, holder_email, holder_phone, billing_country_code, billing_city, billing_state_code,
  billing_street_line_1, billing_street_line_2, billing_zip_code) and the 3DS metadata may be conditionally
  required.

  ## Parameters (required):
    - `:amount` [integer]: Purchase value in cents. ex: 1234 (= R$ 12.34)
    - `:card_expiration` [string]: expiration of the card used for the purchase, in the format YYYY-MM. ex: "2032-12"
    - `:card_number` [string]: number of the card used for the purchase.
    - `:card_security_code` [string]: security code of the card used for the purchase.
    - `:holder_name` [string]: card holder name. ex: "Tony Stark"
    - `:funding_type` [string]: type of funding used for the purchase. ex: "credit", "debit"

  ## Parameters (optional):
    - `:holder_email` [string, default nil]: email associated with the card holder, required if the session's challenge_mode is "enabled" and optional otherwise.
    - `:holder_phone` [string, default nil]: phone number associated with the card holder, required if the session's challenge_mode is "enabled" and optional otherwise.
    - `:holder_id` [string, default nil]: additional card holder identification data.
    - `:installment_count` [integer, default nil]: number of installments the purchase is split into. ex: 1
    - `:billing_country_code` [string, default nil]: billing country code associated with the card used for the purchase, required if the session's challenge_mode is "enabled" and optional otherwise.
    - `:billing_city` [string, default nil]: billing city associated with the card used for the purchase, required if the session's challenge_mode is "enabled" and optional otherwise.
    - `:billing_state_code` [string, default nil]: billing state code associated with the card used for the purchase, required if the session's challenge_mode is "enabled" and optional otherwise.
    - `:billing_street_line_1` [string, default nil]: billing street address associated with the card used for the purchase, required if the session's challenge_mode is "enabled" and optional otherwise.
    - `:billing_street_line_2` [string, default nil]: billing street address complement associated with the card used for the purchase, required if the session's challenge_mode is "enabled" and optional otherwise.
    - `:billing_zip_code` [string, default nil]: billing zip code associated with the card used for the purchase, required if the session's challenge_mode is "enabled" and optional otherwise.
    - `:metadata` [map, default nil]: additional data related to the purchase. If 3DS is enabled, the following fields related to the payer's device are required: userAgent, timezoneOffset, userIp, language.
    - `:soft_descriptor` [string, default nil]: text that will be shown in the holder's bank statement. ex: "my-store"
    - `:tags` [list of strings, default nil]: list of strings for tagging

  Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when a Purchase is created. ex: "5656565656565656"
    - `:card_ending` [string, default nil]: last 4 digits of the card used. ex: "1234"
    - `:card_id` [string, default nil]: unique id of the MerchantCard used for the purchase. ex: "5656565656565656"
    - `:challenge_mode` [string, default nil]: whether 3DS holder verification was used. ex: "enabled", "disabled"
    - `:challenge_url` [string, default nil]: URL to the 3DS challenge, when applicable.
    - `:currency_code` [string, default nil]: currency of the purchase. ex: "BRL"
    - `:end_to_end_id` [string, default nil]: unique transaction id for the acquirer network.
    - `:fee` [integer, default nil]: fee charged when the Purchase is processed. ex: 200 (= R$ 2.00)
    - `:network` [string, default nil]: card network flag. ex: "visa", "mastercard"
    - `:source` [string, default nil]: locator of the entity that generated the purchase. ex: "merchant-session/{sessionId}"
    - `:status` [string, default nil]: current Purchase status. ex: "approved", "confirmed", "canceled", "voided"
    - `:created` [DateTime, default nil]: creation datetime for the Purchase. ex: ~U[2020-03-10 10:30:00.000000Z]
    - `:updated` [DateTime, default nil]: latest update datetime for the Purchase. ex: ~U[2020-03-10 10:30:00.000000Z]
  """
  @enforce_keys [:amount, :card_expiration, :card_number, :card_security_code, :holder_name, :funding_type]
  defstruct [
    :amount,
    :card_expiration,
    :card_number,
    :card_security_code,
    :holder_name,
    :funding_type,
    :holder_email,
    :holder_phone,
    :holder_id,
    :installment_count,
    :billing_country_code,
    :billing_city,
    :billing_state_code,
    :billing_street_line_1,
    :billing_street_line_2,
    :billing_zip_code,
    :metadata,
    :soft_descriptor,
    :tags,
    :id,
    :card_ending,
    :card_id,
    :challenge_mode,
    :challenge_url,
    :currency_code,
    :end_to_end_id,
    :fee,
    :network,
    :source,
    :status,
    :created,
    :updated
  ]

  @type t() :: %__MODULE__{}

  @doc false
  def resource() do
    {
      "Purchase",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Purchase{
      amount: json[:amount],
      card_expiration: json[:card_expiration],
      card_number: json[:card_number],
      card_security_code: json[:card_security_code],
      holder_name: json[:holder_name],
      funding_type: json[:funding_type],
      holder_email: json[:holder_email],
      holder_phone: json[:holder_phone],
      holder_id: json[:holder_id],
      installment_count: json[:installment_count],
      billing_country_code: json[:billing_country_code],
      billing_city: json[:billing_city],
      billing_state_code: json[:billing_state_code],
      billing_street_line_1: json[:billing_street_line_1],
      billing_street_line_2: json[:billing_street_line_2],
      billing_zip_code: json[:billing_zip_code],
      metadata: json[:metadata],
      soft_descriptor: json[:soft_descriptor],
      tags: json[:tags],
      id: json[:id],
      card_ending: json[:card_ending],
      card_id: json[:card_id],
      challenge_mode: json[:challenge_mode],
      challenge_url: json[:challenge_url],
      currency_code: json[:currency_code],
      end_to_end_id: json[:end_to_end_id],
      fee: json[:fee],
      network: json[:network],
      source: json[:source],
      status: json[:status],
      created: json[:created] |> Check.datetime(),
      updated: json[:updated] |> Check.datetime()
    }
  end
end
