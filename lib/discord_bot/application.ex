defmodule DiscordBot.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DiscordBot,
      {Nosedrum.Interactor.Dispatcher, name: Nosedrum.Interactor.Dispatcher}
    ]

    options = [strategy: :rest_for_one, name: DiscordBot.Supervisor]
    Supervisor.start_link(children, options)
  end
end
