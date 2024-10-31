defmodule DiscordBot.Commands.Music.MusicHandler do
  alias DiscordBot.PlayingQueue
  alias Nostrum.Voice

  require Logger

  def get_voice_channel_of_interaction(guild_id, user_id) do
    guild_id
    |> Nostrum.Cache.GuildCache.get!()
    |> Map.get(:voice_states)
    |> Enum.find(%{}, &(&1.user_id == user_id))
    |> Map.get(:channel_id)
  end

  def summon(guild_id, user_id) do
    case get_voice_channel_of_interaction(guild_id, user_id) do
      nil ->
        {:error, "You need to be in a voice channel to use this command"}

      voice_channel_id ->
        Voice.join_channel(guild_id, voice_channel_id)
        :ok
    end
  end

  def play_when_ready(guild_id, url, type, opts \\ []) do
    if Voice.ready?(guild_id) do
      Voice.play(guild_id, url, type, opts)
    else
      Process.sleep(25)
      play_when_ready(guild_id, url, type, opts)
    end
  end

  def play(guild_id, user_id, url, opts \\ []) do
    case summon(guild_id, user_id) do
      :ok ->
        enqueue_music(guild_id, url, :ytdl, opts)
        {:ok, queue_length: PlayingQueue.len(guild_id)}

      {:error, message} ->
        {:error, message}
    end
  end

  def pause(guild_id, user_id) do
    case get_voice_channel_of_interaction(guild_id, user_id) do
      nil ->
        {:error, "You need to be in a voice channel to use this command"}

      _ ->
        Voice.pause(guild_id)
    end

    Voice.pause(guild_id)
  end

  def resume(guild_id, user_id) do
    case get_voice_channel_of_interaction(guild_id, user_id) do
      nil ->
        {:error, "You need to be in a voice channel to use this command"}

      _ ->
        Voice.resume(guild_id)
    end
  end

  def stop(guild_id, user_id) do
    case get_voice_channel_of_interaction(guild_id, user_id) do
      nil ->
        {:error, "You need to be in a voice channel to use this command"}

      _ ->
        Voice.stop(guild_id)
        :ok
    end
  end

  def skip(guild_id, num \\ 1) do
    if num > PlayingQueue.len(guild_id) + 1 do
      {:error, "Cannot skip #{num} songs, only #{PlayingQueue.len(guild_id) + 1} songs in queue"}
    end

    PlayingQueue.pop(guild_id, num - 1)
    playing? = Voice.playing?(guild_id)
    Voice.stop(guild_id)
    unless playing?, do: trigger_play(guild_id)

    {:ok, "Skipped"}
  end

  def peek_queue(guild_id, num_to_show \\ 5) do
    PlayingQueue.peek(guild_id, num_to_show)
    |> Enum.map(&elem(&1, 0))
  end

  def enqueue_music(guild_id, url, type, options) do
    if options[:next],
      do: PlayingQueue.push_front(guild_id, {url, type, options}),
      else: PlayingQueue.push(guild_id, {url, type, options})

    unless Voice.playing?(guild_id), do: trigger_play(guild_id)
  end

  def trigger_play(guild_id) do
    case PlayingQueue.pop(guild_id) do
      [{url, type, options}] ->
        play_when_ready(guild_id, url, type, options)
        Logger.info("Playing next track #{url}")

      [] ->
        Logger.debug("DJ Bot Queue Empty for #{guild_id}")
    end
  end
end
