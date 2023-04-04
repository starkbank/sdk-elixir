defmodule StarkBank.MerchantCountry do
  alias __MODULE__, as: MerchantCountry
  alias StarkBank.Utils.Rest
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups MerchantCountry related functions
  """

  @doc """
  MerchantCountry's codes are used to define countries filters in CorporateRules.

  ## Parameters (required):
    - `:code` [string]: country's code. ex: "BRA"

    ## Attributes (return-only):
    - `:name` [string]: country's name. ex: "Brazil"
    - `:number` [string]: country's number. ex: "076"
    - `:short_code` [string]: country's short code. ex: "BR"
  """
  @enforce_keys [
    :code,
    :name,
    :number,
    :short_code
  ]
  defstruct [
    :code,
    :name,
    :number,
    :short_code
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of MerchantCountry structs previously created in the Stark Bank API

  ## Parameters (optional):
    - `:search` [binary, default nil]: keyword to search for code, name, number or short_code
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of MerchantCountry structs with updated attributes
  """
  @spec query(
          search: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [MerchantCountry.t()]}}
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
          ({:cont, [MerchantCountry.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "MerchantCountry",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %MerchantCountry{
      code: json[:code],
      name: json[:name],
      number: json[:number],
      short_code: json[:short_code],
    }
  end
end
