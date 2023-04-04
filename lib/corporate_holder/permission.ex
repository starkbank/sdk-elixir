defmodule StarkBank.CorporateHolder.Permission do
  alias __MODULE__, as: Permission

  @moduledoc """
  Groups Permission related functions
  """

  @doc """
  The CorporateHolder.Permission object represents access granted to an user for a particular cardholder

  ## Parameters (optional):
    - `:owner_id` [string, default null]: owner unique id. ex: "5656565656565656"
    - `:owner_type` [string, default null]: owner type. ex: "project"

  ## Attributes (return-only):
    - `:owner_email` [string, default null]: owner unique id. ex: "5656565656565656"
    - `:owner_name` [string, default null]: owner type. ex: "project"
    - `:owner_picture_url` [string, default null]: owner unique id. ex: "5656565656565656"
    - `:owner_status` [string, default null]: owner type. ex: "project"
    - `:created` [DateTime]: creation datetime for the Permission. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [
    :owner_id,
    :owner_type,
    :owner_email,
    :owner_name,
    :owner_picture_url,
    :owner_status,
    :created
  ]
  defstruct [
    :owner_id,
    :owner_type,
    :owner_email,
    :owner_name,
    :owner_picture_url,
    :owner_status,
    :created
  ]

  @type t() :: %__MODULE__{}

      @doc false
      def resource() do
        {
          "Permission",
          &resource_maker/1
        }
      end

      @doc false
      def resource_maker(json) do
        %Permission{
          owner_id: json[:owner_id],
          owner_type: json[:owner_type],
          owner_email: json[:owner_email],
          owner_name: json[:owner_name],
          owner_picture_url: json[:owner_picture_url],
          owner_status: json[:owner_status],
          created: json[:created] |> Check.datetime()
        }
      end
    end
