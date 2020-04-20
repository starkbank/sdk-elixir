defmodule StarkBank.Webhook do
  alias __MODULE__, as: Webhook
  alias StarkBank.Utils.Rest, as: Rest
  alias StarkBank.User.Project, as: Project
  alias StarkBank.Error, as: Error
  alias StarkBank.Utils.Checks, as: Checks

  @moduledoc """
  Groups Webhook related functions
  """

  @doc """
  A Webhook is used to subscribe to notification events on a user-selected endpoint.
  Currently available services for subscription are transfer, boleto, boleto-payment,
  and utility-payment

  ## Parameters (required):
    - url [string]: Url that will be notified when an event occurs.
    - subscriptions [list of strings]: list of any non-empty combination of the available services. ex: ["transfer", "boleto-payment"]

  ## Attributes:
    - id [string, default nil]: unique id returned when the log is created. ex: "5656565656565656"
  """
  @enforce_keys [:url, :subscriptions]
  defstruct [:id, :url, :subscriptions]

  @type t() :: %__MODULE__{}

  @doc """
  Send a single Webhook subscription for creation in the Stark Bank API


  ## Keyword Args:
    - url [string]: url to which notification events will be sent to. ex: "https://webhook.site/60e9c18e-4b5c-4369-bda1-ab5fcd8e1b29"
    - subscriptions [list of strings]: list of any non-empty combination of the available services. ex: ["transfer", "boleto-payment"]
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - Webhook struct with updated attributes
  """
  @spec create(user: Project.t(), url: binary, subscriptions: [binary]) ::
          {:ok, Webhook.t()} | {:error, [Error.t()]}
  def create(options \\ []) do
    options = Enum.into(options, %{})

    %{
      url: url,
      subscriptions: subscriptions
    } = options

    webhook = %Webhook{url: url, subscriptions: subscriptions}

    Rest.post_single(
      resource(),
      webhook,
      options
    )
  end

  @doc """
  Same as create(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec create!(user: Project.t(), url: binary, subscriptions: [binary]) :: any
  def create!(options \\ []) do
    options = Enum.into(options, %{})

    %{
      url: url,
      subscriptions: subscriptions
    } = options

    webhook = %Webhook{url: url, subscriptions: subscriptions}

    Rest.post_single!(
      resource(),
      webhook,
      options
    )
  end

  @doc """
  Receive a single Webhook subscription struct previously created in the Stark Bank API by passing its id

  ## Parameters (required):
    - id [string]: struct unique id. ex: "5656565656565656"

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - Webhook struct with updated attributes
  """
  @spec get(binary, user: Project.t()) :: {:ok, Webhook.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t()) :: Webhook.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Webhook subcription structs previously created in the Stark Bank API

  ## Keyword Args:
    - limit [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - stream of Webhook structs with updated attributes
  """
  @spec query(any) ::
          ({:cont, {:ok, [Webhook.t()]}}
           | {:error, [Error.t()]}
           | {:halt, any}
           | {:suspend, any},
           any ->
             any)
  def query(options \\ []) do
    Rest.get_list(resource(), options |> Checks.check_options())
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(any) ::
          ({:cont, [Webhook.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options |> Checks.check_options())
  end

  @doc """
  Delete a Webhook subscription entity previously created in the Stark Bank API

  ## Parameters (required):
    - id [string]: Webhook unique id. ex: "5656565656565656"

  ## Keyword Args:
    - user [Project] (optional): Project struct returned from StarkBank.project().

  ## Return:
    - deleted Webhook with updated attributes
  """
  @spec delete(binary, user: Project.t()) :: {:ok, Webhook.t()} | {:error, [%Error{}]}
  def delete(id, options \\ []) do
    Rest.delete_id(resource(), id, options)
  end

  @doc """
  Same as delete(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec delete!(binary, user: Project.t()) :: Webhook.t()
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
