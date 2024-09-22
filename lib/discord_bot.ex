defmodule DiscordBot do
  use Nostrum.Consumer

  import Nostrum.Struct.Embed
  alias Nostrum.Struct.Interaction
  alias Nostrum.Cache.UserCache
  alias Nostrum.Struct.User
  alias Nostrum.Api
  alias Nostrum.Struct.Guild.Member

  def handle_event({:READY, _event, _ws_state}) do
    commands = [
      %{
        name: "ping",
        description: "Teste de latência"
      },
      %{
        name: "clima",
        description: "Saiba como está o clima na cidade",
        options: [
          %{
            type: 3,
            name: "cidade",
            description: "cidade para verificar o clima",
            required: true
          }
        ]
      }
    ]

    Enum.each(
      commands,
      &Nostrum.Api.create_guild_application_command(1_230_493_944_912_154_664, &1)
    )
  end

  def handle_event(
        {:INTERACTION_CREATE, %Interaction{data: %{name: name}} = interaction, _ws_state}
      ) do
    handle_command(name, interaction)
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

  defp handle_command(command, %Interaction{} = interaction) do
    options = interaction.data.options

    case command do
      "clima" ->
        city = Enum.at(options, 0).value
        weather = get_weather_result(city)

        response = %{
          type: 4,
          data: %{
            content: weather
          }
        }

        Api.create_interaction_response(interaction, response)

      "ping" ->
        response = %{
          type: 4,
          data: %{
            content: "Pong!"
          }
        }

        Api.create_interaction_response(interaction, response)

      _ ->
        "Comando desconhecido"
    end
  end

  defp get_weather_result(city) do
    api_key = Application.fetch_env!(:discord_bot, :openwm_api_key)
    q = URI.encode(city)

    url =
      "https://api.openweathermap.org/data/2.5/weather?q=#{q}&appid=#{api_key}&units=metric"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        weather = Jason.decode!(body)
        temp = weather["main"]["temp"]

        "Temperatura em #{city}: #{temp}°C"

      _ ->
        "Cidade não encontrada"
    end
  end
end
