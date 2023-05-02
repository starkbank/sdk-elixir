defmodule StarkBank.CardMethod do
  alias __MODULE__, as: CardMethod
  alias StarkBank.Utils.Rest
  # alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups CardMethod related functions
  """

  @doc """
  CardMethod's codes are used to define methods filters in CorporateRules.

  ## Parameters (required):
    - `:code` [integer]: method's code. Options: "chip", "token", "server", "manual", "magstripe", "contactless"

  ## Attributes (return-only):
    - `:name` [string]: method's name. ex: "token"
    - `:number` [string]: method's number. ex: "81"
  """
  @enforce_keys [
    :code,
    :name,
    :number
  ]
  defstruct [
    :code,
    :name,
    :number
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of CardMethod structs previously created in the Stark Bank API

  ## Parameters (optional):
    - `:search` [binary, default nil]: keyword to search for code, name, number or short_code
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of CardMethod structs with updated attributes
  """
  @spec query(
          search: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [CardMethod.t()]}}
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
          search: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, [CardMethod.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "CardMethod",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %CardMethod{
      code: json[:code],
      name: json[:name],
      number: json[:number]
    }
  end
end
