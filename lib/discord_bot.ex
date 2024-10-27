defmodule DiscordBot do
  use Nostrum.Consumer

  import Nostrum.Struct.Embed
  alias DiscordBot.ApplicationCommandLoader
  alias Nostrum.Cache.UserCache
  alias Nostrum.Struct.User
  alias Nostrum.Struct.Guild.Member
  alias Nosedrum.Storage.Dispatcher

  def handle_event({:READY, _, _}),
    do:
      Application.fetch_env!(:discord_bot, :main_guild_id) |> ApplicationCommandLoader.load_all()

  def handle_event({:INTERACTION_CREATE, intr, _}), do: Dispatcher.handle_interaction(intr)

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

  def handle_event(_), do: :noop
end
