defmodule StarkBank.Webhook do

  @moduledoc """
  Groups Webhook related functions
  """

  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.Webhook.Data, as: Webhook
  alias StarkBank.User.Project.Data, as: Project
  alias StarkBank.Error, as: Error

  @doc """
  # Create Webhook subscription

  Send a single Webhook subscription for creation in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - url [string]: url to which notification events will be sent to. ex: "https://webhook.site/60e9c18e-4b5c-4369-bda1-ab5fcd8e1b29"
    - subscriptions [list of strings]: list of any non-empty combination of the available services. ex: ["transfer", "boleto-payment"]

  ## Return:
    - Webhook struct with updated attributes
  """
  @spec create(Project.t(), binary, [binary]) ::
    {:ok, [Webhook.t()]} | {:error, [Error.t()]}
  def create(user, url, subscriptions) do
    webhook = %Webhook{url: url, subscriptions: subscriptions}
    Rest.post_single(
      user,
      resource(),
      webhook
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(Project.t(), binary, [binary]) :: any
  def create!(user, url, subscriptions) do
    webhook = %Webhook{url: url, subscriptions: subscriptions}
    Rest.post_single!(
      user,
      resource(),
      webhook
    )
  end

  @doc """
  # Retrieve a specific Webhook subscription

  Receive a single Webhook subscription struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Return:
    - Webhook struct with updated attributes
  """
  @spec get(Project, binary) :: {:ok, Webhook.t()} | {:error, [%Error{}]}
  def get(user, id) do
    Rest.get_id(user, resource(), id)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(Project, binary) :: Webhook.t()
  def get!(user, id) do
    Rest.get_id!(user, resource(), id)
  end

  @doc """
  # Retrieve Webhook subcriptions

  Receive a stream of Webhook subcription structs previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().

  ## Parameters (optional):
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35

  ## Return:
    - stream of Webhook structs with updated attributes
  """
  @spec query(Project.t(), any) ::
          ({:cont, {:ok, [Webhook.t()]}} | {:error, [Error.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query(user, options \\ []) do
    %{limit: limit} =
      Enum.into(options, %{limit: nil})
    Rest.get_list(user, resource(), limit)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(Project.t(), any) ::
          ({:cont, [Webhook.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(user, options \\ []) do
    %{limit: limit} =
      Enum.into(options, %{limit: nil})
    Rest.get_list!(user, resource(), limit)
  end

  @doc """
  # Delete a Webhook subscription entity

  Delete a Webhook subscription entity previously created in the Stark Bank API

  ## Parameters (required):
    - user [Project]: Project struct returned from StarkBank.project().
    - id [string]: Webhook unique id. ex: "5656565656565656"

  ## Return:
    - deleted Webhook with updated attributes
  """
  @spec delete(Project, binary) :: {:ok, Webhook.t()} | {:error, [%Error{}]}
  def delete(user, id) do
    Rest.delete_id(user, resource(), id)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(Project, binary) :: Webhook.t()
  def delete!(user, id) do
    Rest.delete_id!(user, resource(), id)
  end

  @doc false
  def resource() do
    {
      "Webhook",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Webhook{
      id: json[:id],
      url: json[:url],
      subscriptions: json[:subscriptions]
    }
  end
end
