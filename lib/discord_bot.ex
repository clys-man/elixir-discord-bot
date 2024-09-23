defmodule DiscordBot do
  use Nostrum.Consumer

  import Nostrum.Struct.Embed
  alias Nostrum.Cache.UserCache
  alias Nostrum.Struct.User
  alias Nostrum.Struct.Guild.Member

  @commands %{
    "ping" => DiscordBot.Commands.Ping,
    "pokemon" => DiscordBot.Commands.Pokemon,
    "clima" => DiscordBot.Commands.Clima
  }

  def handle_event({:READY, _data, _ws_state}) do
    load_commands()
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    Nosedrum.Interactor.Dispatcher.handle_interaction(interaction)
  end

  def handle_event({:GUILD_MEMBER_ADD, {_, %Member{} = member}, _ws_state}) do
    embed_color = Application.fetch_env!(:discord_bot, :embed_color)
    welcome_channel_id = Application.fetch_env!(:discord_bot, :welcome_channel_id)
    {_, %User{} = user} = UserCache.get(member.user_id)

    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("🎉 Seja bem-vindo(a), #{user.username}! 🎉")
      |> put_description(
        "Estamos felizes em ter você aqui! Sinta-se à vontade para explorar os canais e interagir com a galera. Se precisar de ajuda, não hesite em nos chamar."
      )
      |> put_timestamp(:os.system_time(:second) |> DateTime.from_unix!())
      |> put_color(embed_color)
      |> put_field("📜 Regras", "Não deixe de conferir as regras no canal de regras.")
      |> put_field("💬 Apresente-se", "Conte um pouco sobre você no canal de apresentações!", true)
      |> put_author(user.username, nil, User.avatar_url(user))
      |> put_thumbnail(User.avatar_url(user))

    Nostrum.Api.create_message(welcome_channel_id, embeds: [embed])
  end

  defp load_commands do
    @commands
    |> Enum.each(&load_command/1)
  end

  defp load_command({name, module}) do
    guild_id = Application.fetch_env!(:discord_bot, :main_guild_id)

    case Nosedrum.Interactor.Dispatcher.add_command(name, module, guild_id) do
      {:ok, _} -> IO.puts("Registered #{name} command.")
      e -> IO.inspect(e, label: "An error occurred registering the #{name} command")
    end
  end
end
