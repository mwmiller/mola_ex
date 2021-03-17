defmodule Mola.MixProject do
  use Mix.Project

  def project do
    [
      app: :mola,
      version: "0.2.0",
      elixir: "~> 1.9",
      name: "mola",
      source_url: "https://github.com/mwmiller/mola_ex",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.23", only: :dev},
      {:flow, "~> 1.0"}
    ]
  end

  defp description do
    """
    mola - poker high hand ranking and enumeration
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Matt Miller"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mwmiller/mola_ex"}
    ]
  end
end
