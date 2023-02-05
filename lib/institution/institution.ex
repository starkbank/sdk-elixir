defmodule StarkBank.Institution do
    alias __MODULE__, as: Institution
    alias StarkBank.Utils.Rest
    alias StarkBank.User.Project
    alias StarkBank.User.Organization
    alias StarkBank.Error

    @moduledoc """
    Groups Institution related functions
    """

    @doc """
    This resource is used to get information on the institutions that are recognized by the Brazilian Central Bank.
    Besides the display name and full name, they also include the STR code (used for TEDs) and the SPI Code
    (used for Pix) for the institutions. Either of these codes may be empty if the institution is not registered on
    that Central Bank service.

    ## Attributes (return-only):
      - `:display_name` [string]: short version of the institution name that should be displayed to end users. ex: "Stark Bank"
      - `:name` [string]: full version of the institution name. ex: "Stark Bank S.A."
      - `:spi_code` [string]: SPI code used to identify the institution on Pix transactions. ex: "20018183"
      - `:str_code` [string]: STR code used to identify the institution on TED transactions. ex: "123"
    """
    defstruct [
      :display_name,
      :name,
      :spi_code,
      :str_code
    ]

    @type t() :: %__MODULE__{}

    @doc """
    Receive a list of Institution objects that are recognized by the Brazilian Central bank for Pix and TED transactions

    ## Options:
      - `:limit` [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      - `:search` [string, default nil]: part of the institution name to be searched. ex: "stark"
      - `:spi_codes` [list of strings, default nil]: list of SPI (Pix) codes to be searched. ex: ["20018183"]
      - `:str_codes` [list of strings, default nil]: list of STR (TED) codes to be searched. ex: ["260"]
      - `:user` [Organization/Project, default nil]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project or organization has not been set in configs.

    ## Return:
      - list of Institution objects with updated attributes
    """
    @spec query(
            limit: integer,
            search: binary,
            spi_codes: [binary],
            str_codes: [binary],
            user: Project.t() | Organization.t()
          ) ::
            ({:cont, {:ok, [Institution.t()]}}
            | {:error, [Error.t()]}
            | {:halt, any}
            | {:suspend, any},
            any ->
              any)
    def query(options \\ []) do
      case Rest.get_page(resource(), options) do
        {:ok, {_cursor, entities}} -> {:ok, entities}
        {:error, error} -> {:error, error}
      end
    end

    @doc """
    Same as query(), but it will unwrap the error tuple and raise in case of errors.
    """
    @spec query!(
            limit: integer,
            search: binary,
            spi_codes: [binary],
            str_codes: [binary],
            user: Project.t() | Organization.t()
      ) ::
            ({:cont, [Institution.t()]} | {:halt, any} | {:suspend, any}, any -> any)
    def query!(options \\ []) do
      Rest.get_page!(resource(), options) |> elem(1)
    end

    @doc false
    def resource() do
      {
        "Institution",
        &resource_maker/1
      }
    end

    @doc false
    def resource_maker(json) do
      %Institution{
        display_name: json[:display_name],
        name: json[:name],
        spi_code: json[:spi_code],
        str_code: json[:str_code]
      }
    end
end
