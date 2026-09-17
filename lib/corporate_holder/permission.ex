defmodule StarkBank.CorporateHolder.Permission do
  alias __MODULE__, as: Permission
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.API

  @moduledoc """
  Groups CorporateHolder.Permission related functions
  """

  @doc """
  Permission struct represents access granted to an user for a particular cardholder

  ## Parameters (optional):
    - `:owner_id` [string, default nil]: owner unique id. ex: "5656565656565656"
    - `:owner_type` [string, default nil]: owner type. ex: "project"

  Attributes (return-only):
    - `:owner_email` [string, default nil]: email address of the owner. ex: "tony@starkbank.com"
    - `:owner_name` [string, default nil]: name of the owner. ex: "Tony Stark"
    - `:owner_picture_url` [string, default nil]: profile picture url of the owner. ex: "https://storage.googleapis.com/api-ms-workspace-sbx.appspot.com/pictures/member/6227829385592832?20230404164942"
    - `:owner_status` [string, default nil]: current owner status. ex: "active", "blocked", "canceled"
    - `:created` [DateTime, default nil]: creation datetime for the Permission. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
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
  def parse_permissions(nil), do: nil

  def parse_permissions(permissions) do
    Enum.map(permissions, fn
      %Permission{} = permission -> permission
      permission -> permission |> API.from_api_json(&resource_maker/1)
    end)
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
