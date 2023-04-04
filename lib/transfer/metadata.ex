defmodule StarkBank.Transfer.Metadata do
  alias __MODULE__, as: Metadata

  @moduledoc """
  Groups Metadata related functions
  """

  @doc """
  The Transfer.Metadata object contains additional information about the Transfer struct.

  ## Parameters (required):
    - `:authentication` [string]: Central Bank’s unique ID for Pix transactions (EndToEndID). ex: “E200181832023031715008Scr7tD63TS”
  """
  @enforce_keys [
    :authentication
  ]
  defstruct [
    :authentication
  ]

  @type t() :: %__MODULE__{}

      @doc false
      def resource() do
        {
          "Metadata",
          &resource_maker/1
        }
      end

      @doc false
      def resource_maker(json) do
        %Metadata{
          authentication: json[:authentication]
        }
      end
    end
