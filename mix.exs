defmodule StarkBank.MixProject do
  use Mix.Project

  def project do
    [
      app: :stark_bank,
      name: :stark_bank,
      organization: :stark_bank,
      licenses: [:MIT],
      version: "1.0.0",
      homepage_url: "https://starkbank.com",
      source_url: "https://github.com/starkbank/sdk-elixir",
      description: description(),
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp description do
    "SDK to make integrations with the Stark Bank API easier."
  end

  def application do
    []
  end

  defp deps do
    [
      {:jason, "~> 1.1"}
    ]
  end
end
