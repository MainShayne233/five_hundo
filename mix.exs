defmodule FiveHundo.Mixfile do
  use Mix.Project

  def project do
    [
      app: :five_hundo,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
    ]
  end

  def application do
    [
      mod: {FiveHundo.Application, []},
      extra_applications: [:logger, :runtime_tools],
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:calendar, "~> 0.17.2"},
      {:cowboy, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:phoenix, "~> 1.3.0-rc"},
      {:phoenix_ecto, "~> 3.2"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
    ]
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
