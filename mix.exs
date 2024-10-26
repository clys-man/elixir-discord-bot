defmodule DiscordBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :discord_bot,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {DiscordBot.Application, []}
    ]
  end

  defp deps do
    [
      {:nostrum, github: "Kraigie/nostrum", override: true},
      {:nosedrum, github: "jchristgit/nosedrum", override: true},
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:ollama, "0.7.1"}
    ]
  end
end
