defmodule DiscordBot.Commands.Music.Command do
  @behaviour Nosedrum.ApplicationCommand

  alias DiscordBot.Commands.Music.Subcommands.Resume
  alias DiscordBot.Commands.Music.Subcommands.Pause
  alias DiscordBot.Commands.Music.Subcommands.Play

  def name(), do: "music"

  @impl true
  def description(), do: "Demonstrating how to use sub commands"

  @impl true
  def command(interaction) do
    [
      type:
        {:deferred_channel_message_with_source,
         {&process_subcommand/2, [interaction.data.options, interaction]}}
    ]
  end

  def process_subcommand([%{name: "play", options: play_args}], interaction),
    do: Play.execute(play_args, interaction)

  def process_subcommand([%{name: "pause"}], interaction),
    do: Pause.execute(interaction)

  def process_subcommand([%{name: "resume"}], interaction),
    do: Resume.execute(interaction)

  def process_subcommand([%{options: next_layer}], interaction) when next_layer != nil,
    do: process_subcommand(next_layer, interaction)

  def process_subcommand(_),
    do: "Error finding sub-command. Are you sure you're matching the correct sub-command names?"

  @impl true
  def options do
    [
      %{
        type: :sub_command,
        name: "play",
        description: "Play a song from YouTube",
        options: [
          %{
            type: :string,
            name: "url",
            description: "The URL of the YouTube video",
            required: true
          }
        ]
      },
      %{
        type: :sub_command,
        name: "pause",
        description: "Pause the current song"
      },
      %{
        type: :sub_command,
        name: "resume",
        description: "Resume the current song"
      }
    ]
  end

  @impl true
  def type(), do: :slash
end
