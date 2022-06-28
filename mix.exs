defmodule BitcoinLib.MixProject do
  use Mix.Project

  def project do
    [
      app: :bitcoinlib,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      xref: [exclude: [:crypto]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:binary, "0.0.4"},
      {:exbase58, "~> 1.0"},
      {:pbkdf2_elixir, "~> 2.0"},
      {:curvy, "~> 0.3.0"}
    ]
  end
end
