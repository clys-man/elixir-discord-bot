defmodule DiscordBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DiscordBot,
      {Nosedrum.Storage.Dispatcher, name: Nosedrum.Storage.Dispatcher},
      DiscordBot.PlayingQueue
    ]

    options = [strategy: :rest_for_one, name: DiscordBot.Supervisor]
    Supervisor.start_link(children, options)
  end
end
