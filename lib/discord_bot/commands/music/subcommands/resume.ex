defmodule DiscordBot.Commands.Music.Subcommands.Resume do
  alias DiscordBot.Commands.Music.MusicHandler

  def execute(interaction) do
    case MusicHandler.resume(interaction.guild_id, interaction.user.id) do
      :ok ->
        [content: "Resume", ephemeral: true]

      {:error, message} ->
        [content: message, ephemeral: true]
    end
  end
end
