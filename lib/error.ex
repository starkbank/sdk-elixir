defmodule StarkBank.Error do
  @moduledoc """
  Error generated on interactions with the API

  If the error code is:
    - "internalServerError": the API has run into an internal error. If you ever stumble upon this one, rest assured that the development team is already rushing in to fix the mistake and get you back up to speed.
    - "unknownException": a request encounters an error that has not been sent by the API, such as connectivity problems.
    - any other binary: the API has detected a mistake in your request

  ## Attributes:
    - code [string]: defines de error code. ex: "invalidCredentials"
    - message [string]: explains the detected error. ex: "Provided digital signature in the header Access-Signature does not check out. See https://docs.api.starkbank.com/#auth for details."
  """

  defstruct [:code, :message]
end
