defmodule BitcoinLib.MixProject do
  use Mix.Project

  @version "0.4.4"

  def project do
    [
      app: :bitcoinlib,
      version: @version,
      description: "Generate private/public keys and addresses for the bitcoin network",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      xref: [exclude: [:crypto]],

      # Docs
      name: "BitcoinLib",
      source_url: "https://github.com/roosoft/bitcoinlib",
      homepage_url: "https://github.com/roosoft/bitcoinlib",
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  def package do
    [
      maintainers: ["Marc Lacoursière"],
      licenses: ["UNLICENCE"],
      links: %{"GitHub" => "https://github.com/roosoft/bitcoinlib"}
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "BitcoinLib",
      extras: docs_extras(),
      extra_section: "GUIDES",
      groups_for_extras: docs_groups_for_extras(),
      assets: "/guides/assets",
      source_ref: @version,
      source_url: "https://github.com/roosoft/bitcoinlib"
    ]
  end

  def docs_extras do
    [
      "README.md",
      "guides/tutorial/tutorial-private-key.md",
      "guides/tutorial/tutorial-derivation.md",
      "guides/tutorial/tutorial-public-key.md",
      "guides/tutorial/tutorial-address.md",
      "guides/tutorial/tutorial-transaction.md",
      "guides/examples.md",
      "guides/links.md"
    ]
  end

  def docs_groups_for_extras() do
    [
      Tutorial: ~r/guides\/tutorial\/.?/
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:binary, "~> 0.0.5"},
      {:b58, "~> 1.0"},
      {:pbkdf2_elixir, "~> 2.0"},
      {:curvy, "~> 0.3.0"},
      {:bip0173, "~> 0.1.2"}
    ]
  end
end
