defmodule DiscordBot.Commands.Music.Subcommands.Play do
  alias DiscordBot.Commands.Music.MusicHandler

  def execute([play_args], interaction) do
    IO.inspect(interaction)
    interaction = %Nostrum.Struct.Interaction{interaction | guild_id: interaction.guild_id}
    guild_id = interaction.guild_id
    user_id = interaction.user.id
    url = play_args.value

    case MusicHandler.play(guild_id, user_id, url) do
      {:ok, [queue_length: queue_length]} ->
        if queue_length == 0 do
          [content: "Now playing #{url}", ephemeral: true]
        else
          [content: "Audio queued, ##{queue_length} in queue", ephemeral: true]
        end

      {:error, message} ->
        [content: message, ephemeral: true]
    end
  end
end
