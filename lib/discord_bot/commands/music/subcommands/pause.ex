defmodule DiscordBot.Commands.Music.Subcommands.Pause do
  alias DiscordBot.Commands.Music.MusicHandler

  def execute(interaction) do
    pause = MusicHandler.pause(interaction.guild_id, interaction.user.id)

    case pause do
      _ ->
        [content: "Paused", ephemeral: true]
    end
  end
end
