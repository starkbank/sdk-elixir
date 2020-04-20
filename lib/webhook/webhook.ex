defmodule StarkBank.Webhook do
  alias __MODULE__, as: Webhook
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups Webhook related functions
  """

  @doc """
  A Webhook is used to subscribe to notification events on a user-selected endpoint.
  Currently available services for subscription are transfer, boleto, boleto-payment,
  and utility-payment

  ## Parameters (required):
    - `:url` [string]: Url that will be notified when an event occurs.
    - `:subscriptions` [list of strings]: list of any non-empty combination of the available services. ex: ["transfer", "boleto-payment"]

  ## Attributes:
    - `:id` [string, default nil]: unique id returned when the log is created. ex: "5656565656565656"
  """
  @enforce_keys [:url, :subscriptions]
  defstruct [:id, :url, :subscriptions]

  @type t() :: %__MODULE__{}

  @doc """
  Send a single Webhook subscription for creation in the Stark Bank API

  ## Parameters (required):
    - `:url` [string]: url to which notification events will be sent to. ex: "https://webhook.site/60e9c18e-4b5c-4369-bda1-ab5fcd8e1b29"
    - `:subscriptions` [list of strings]: list of any non-empty combination of the available services. ex: ["transfer", "boleto-payment"]

  ## Parameters (optional):
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Webhook struct with updated attributes
  """
  @spec create(user: Project.t() | nil, url: binary, subscriptions: [binary]) ::
          {:ok, Webhook.t()} | {:error, [Error.t()]}
  def create(parameters \\ []) do
    %{user: user, url: url, subscriptions: subscriptions} =
      Enum.into(
        parameters |> Check.enforced_keys([:url, :subscriptions]),
        %{user: nil}
      )

    Rest.post_single(
      resource(),
      %Webhook{url: url, subscriptions: subscriptions},
      %{user: user}
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(user: Project.t() | nil, url: binary, subscriptions: [binary]) :: any
  def create!(parameters \\ []) do
    %{user: user, url: url, subscriptions: subscriptions} =
      Enum.into(
        parameters |> Check.enforced_keys([:url, :subscriptions]),
        %{user: nil, url: nil, subscriptions: nil}
      )

    Rest.post_single!(
      resource(),
      %Webhook{url: url, subscriptions: subscriptions},
      %{user: user}
    )
  end

  @doc """
  Receive a single Webhook subscription struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Webhook struct with updated attributes
  """
  @spec get(binary, user: Project.t() | nil) :: {:ok, Webhook.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | nil) :: Webhook.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Webhook subcription structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of Webhook structs with updated attributes
  """
  @spec query(
          limit: integer,
          user: Project.t()
        ) ::
          ({:cont, {:ok, [Webhook.t()]}}
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
          limit: integer,
          user: Project.t()
        ) ::
          ({:cont, [Webhook.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc """
  Delete a Webhook subscription entity previously created in the Stark Bank API

  ## Parameters (required):
    - `id` [string]: Webhook unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - deleted Webhook with updated attributes
  """
  @spec delete(binary, user: Project.t() | nil) :: {:ok, Webhook.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t() | nil) :: Webhook.t()
  def delete!(id, options \\ []) do
    Rest.delete_id!(resource(), id, options)
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
