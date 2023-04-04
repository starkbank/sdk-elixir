defmodule StarkBank.MerchantCategory do
  alias __MODULE__, as: MerchantCategory
  alias StarkBank.Utils.Rest
  alias StarkBank.User.Project
  alias StarkBank.User.Organization
  alias StarkBank.Error

  @moduledoc """
  Groups MerchantCategory related functions
  """

  @doc """
  MerchantCategory's codes and types are used to define categories filters in CorporateRules.
  A MerchantCategory filter must define exactly one parameter between code and type.
  A type, such as "food", "services", etc., defines an entire group of merchant codes,
  whereas a code only specifies a specific MCC.

  ## Parameters (conditionally required):
    - `:code` [string, default nil]: category's code. ex: "veterinaryServices", "fastFoodRestaurants"
    - `:type` [string, default nil]: category's type. ex: "pets", "food"

  ## Attributes (return-only):
    - `:name` [string]: category's name. ex: "Veterinary services", "Fast food restaurants"
    - `:number` [string]: category's number. ex: "742", "5814"
  """
  @enforce_keys [
    :code,
    :type,
    :name,
    :number
  ]
  defstruct [
    :code,
    :type,
    :name,
    :number
  ]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a stream of MerchantCategory structs previously created in the Stark Bank API

  ## Parameters (optional):
    - `:search` [binary, default nil]: keyword to search for code, type, name or number
    - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

  ## Return:
    - stream of MerchantCategory structs with updated attributes
  """
  @spec query(
          search: binary,
          user: Project.t() | Organization.t()
        ) ::
          ({:cont, {:ok, [MerchantCategory.t()]}}
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
          ({:cont, [MerchantCategory.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "MerchantCategory",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %MerchantCategory{
      code: json[:code],
      type: json[:type],
      name: json[:name],
      number: json[:number]
    }
  end
end
