defmodule DiscordBot.Commands.Ping do
  @behaviour Nosedrum.ApplicationCommand

  def name(), do: "ping"

  @impl true
  def description() do
    "Ping"
  end

  @impl true
  def command(_interaction) do
    [
      content: "pong",
      ephemeral?: true
    ]
  end

  @impl true
  def type() do
    :slash
  end
end
