defmodule BitcoinLib.MixProject do
  use Mix.Project

  def project do
    [
      app: :bitcoinlib,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      xref: [exclude: [:crypto]],

      # Docs
      name: "BitcoinLib",
      source_url: "https://github.com/roosoft/bitcoinlib",
      homepage_url: "https://github.com/roosoft/bitcoinlib",
      docs: [
        # The main page in the docs
        main: "BitcoinLib",
        extras: ["README.md"]
      ]
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
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: [:dev]},
      {:binary, "0.0.4"},
      {:exbase58, "~> 1.0"},
      {:pbkdf2_elixir, "~> 2.0"},
      {:curvy, "~> 0.3.0"},
      {:bip0173, "~> 0.1.2"}
    ]
  end
end
