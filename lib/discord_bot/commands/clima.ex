defmodule DiscordBot.Commands.Clima do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description() do
    "Saiba como está o clima de uma cidade"
  end

  @impl true
  def command(interaction) do
    [%{name: "cidade", value: city}] = interaction.data.options

    weather = get_weather_result(city)

    [
      content: weather
    ]
  end

  @impl true
  def type() do
    :slash
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "cidade",
        description: "cidade para verificar o clima",
        required: true
      }
    ]
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
