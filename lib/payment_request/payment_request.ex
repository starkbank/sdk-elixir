defmodule StarkBank.PaymentRequest do
    alias __MODULE__, as: PaymentRequest
    alias StarkBank.Utils.Rest
    alias StarkBank.Utils.Check
    alias StarkBank.Utils.API
    alias StarkBank.User.Project
    alias StarkBank.Error
    alias StarkBank.Boleto, as: Boleto
    alias StarkBank.Transfer, as: Transfer
    alias StarkBank.Transaction, as: Transaction
    alias StarkBank.BoletoPayment, as: BoletoPayment
    alias StarkBank.UtilityPayment, as: UtilityPayment

    @moduledoc """
    Groups PaymentRequest related functions
    """

    @doc """
    A PaymentRequest is an indirect request to access a specific cash-out service
    (such as Transfer, BoletoPayments, etc.) which goes through the cost center
    approval flow on our web banking. To emit a PaymentRequest, you must direct it to
    a specific cost center by its ID, which can be retrieved on our web banking at the
    cost center page.

    ## Parameters (required):
    - `:center_id` [string]: target cost center ID. ex: "5656565656565656"
    - `:payment` [Transfer, BoletoPayment, UtilityPayment, Transaction or map]: payment entity that should be approved and executed.

    ## Parameters (conditionally required):
    - `:type` [string]: payment type, inferred from the payment parameter if it is not a map. ex: "transfer", "boleto-payment"

    ## Parameters (optional):
    - `:due` [Date, DateTime, Time or string]: Payment target date in ISO format. ex: 2020-12-31
    - `:tags` [list of strings]: list of strings for tagging

    ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when PaymentRequest is created. ex: "5656565656565656"
    - `:amount` [integer, default nil]: PaymentRequest amount. ex: 100000 = R$1.000,00
    - `:status` [string, default nil]: current PaymentRequest status.ex: "pending" or "approved"
    - `:actions` [list of maps, default nil]: list of actions that are affecting this PaymentRequest. ex: [%{"type": "member", "id": "56565656565656, "action": "requested"}]
    - `:updated` [DateTime, default nil]: latest update datetime for the PaymentRequest. ex: 2020-12-31
    - `:created` [DateTime, default nil]: creation datetime for the PaymentRequest. ex: 2020-12-31
    """

    @enforce_keys [:center_id, :payment]
    defstruct [
        :id,
        :payment,
        :center_id,
        :due,
        :tags,
        :amount,
        :status,
        :actions,
        :updated,
        :created,
        :type
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Sends a list of PaymentRequests structs for creating in the Stark Bank API

    ## Paramenters (required):
    - `payment_requests` [list of PaymentRequest structs]: list of PaymentRequest objects to be created in the API

    ## Options:
    - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

    ## Return:
    - list of PaymentRequest structs with updated attributes
    """
    @spec create([PaymentRequest.t() | map()], user: Project.t() | nil) ::
            {:ok, [PaymentRequest.t()]} | {:error, [Error.t()]}
    def create(payment_requests, options \\ []) do
        case Rest.post(
            resource(),
            Enum.map(payment_requests, fn request -> %PaymentRequest{request | type: get_type(request.payment)} end),
            options
        ) do
            {:ok, requests} -> {:ok, requests |> Enum.map(&parse_request!/1)}
            response -> response
        end
    end

    @doc """
    Same as create(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec create!([PaymentRequest.t() | map()], user: Project.t() | nil) :: any
    def create!(payment_requests, options \\ []) do
        Rest.post!(
            resource(),
            Enum.map(payment_requests, fn request -> %PaymentRequest{request | type: get_type(request.payment)} end),
            options
        ) |> Enum.map(&parse_request!/1)
    end

    @doc """
    Receive a stream of PaymentRequest structs previously created by this user in the Stark Bank API

    ## Options:
        - `:limit` [integer, default nil]: maximum number of structs to be retrieved. Unlimited if nil. ex: 35
        - `:after` [Date, DateTime or string, default nil]: date filter for structs created only after specified date. ex: ~D[2020-03-25]
        - `:before` [Date, DateTime or string, default nil]: date filter for structs created only before specified date. ex: ~D[2020-03-25]
        - `:sort` [string, default "-created"]: sort order considered in response. Valid options are "-created" or "-due".
        - `:status` [string, default nil]: filter for status of retrieved structs. ex: "paid" or "registered"
        - `:type` [string, default nil]: payment type, inferred from the payment parameter if it is not a dictionary. ex: "transfer", "boleto-payment"
        - `:tags` [list of strings, default nil]: tags to filter retrieved structs. ex: ["tony", "stark"]
        - `:ids` [list of strings, default nil]: list of ids to filter retrieved structs. ex: ["5656565656565656", "4545454545454545"]
        - `:user` [Project]: Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

    ## Return:
        - stream of PaymentRequest structs with updated attributes
    """
    @spec query(
            limit: integer,
            after: Date.t() | DateTime.t() | binary,
            before: Date.t() | DateTime.t() | binary,
            sort: binary,
            status: binary,
            type: binary,
            tags: [binary],
            ids: [binary],
            user: Project.t()
            ) ::
            ({:cont, {:ok, [PaymentRequest.t()]}}
            | {:error, [Error.t()]}
            | {:halt, any}
            | {:suspend, any},
            any ->
                any)
    def query(options \\ []) do
        Rest.get_list(resource(), options) |> Enum.map(&parse_request/1)
    end

    @doc """
    Same as query(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec query!(
            limit: integer,
            after: Date.t() | DateTime.t() | binary,
            before: Date.t() | DateTime.t() | binary,
            sort: binary,
            status: binary,
            type: binary,
            tags: [binary],
            ids: [binary],
            user: Project.t()
            ) ::
            ({:cont, [PaymentRequest.t()]} | {:halt, any} | {:suspend, any}, any -> any)
    def query!(options \\ []) do
        Rest.get_list!(resource(), options) |> Enum.map(&parse_request!/1)
    end

    defp get_type(resource) do
        case resource do
            %Transfer{} -> "transfer"
            %Transaction{} -> "transaction"
            %BoletoPayment{} -> "boleto-payment"
            %UtilityPayment{} -> "utility-payment"
        end
    end

    defp parse_request(request_tuple) do
        case request_tuple do
            {:ok, request} -> {:ok, parse_request!(request)}
            _ -> request_tuple
        end
    end

    defp parse_request!(request) do
        %PaymentRequest{request | payment: request.payment |> API.from_api_json(resource_maker_by_type(request.type))}
    rescue
        CaseClauseError -> request
    end

    defp resource_maker_by_type(subscription) do
        case subscription do
            "transfer" -> &Transfer.resource_maker/1
            "transaction" -> &Transaction.resource_maker/1
            "boleto" -> &Boleto.resource_maker/1
            "boleto-payment" -> &BoletoPayment.resource_maker/1
            "utility-payment" -> &UtilityPayment.resource_maker/1
        end
    end

    @doc false
    def resource() do
        {
            "PaymentRequest",
            &resource_maker/1
        }
    end

    @doc false
    def resource_maker(json) do
        %PaymentRequest{
            id: json[:id],
            payment: json[:payment],
            center_id: json[:center_id],
            type: json[:type],
            tags: json[:tags],
            amount: json[:amount],
            status: json[:status],
            actions: json[:actions],
            updated: json[:updated] |> Check.datetime(),
            created: json[:created] |> Check.datetime(),
            due: json[:due] |> Check.datetime()
        }
    end
end
