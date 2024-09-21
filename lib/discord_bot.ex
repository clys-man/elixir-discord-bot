defmodule DiscordBot do
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    token = Application.fetch_env!(:discord_bot, :token)

    cond do
      msg.author.bot ->
        :ignore

      String.starts_with?(msg.content, "#{token}ppt ") ->
        handle_ppt(msg)

      String.starts_with?(msg.content, "#{token}ping") ->
        Api.create_message(msg.channel_id, "Pong!")

      String.starts_with?(msg.content, "#{token}weather ") ->
        handle_weather(msg)

      true ->
        :ignore
    end
  end

  defp handle_ppt(msg) do
    case String.split(msg.content, " ", parts: 2, trim: true) do
      [_, choose] -> get_ppt_result(msg, choose)
      _ -> Api.create_message(msg.channel_id, "Opção invalida")
    end
  end

  defp handle_weather(msg) do
    case String.split(msg.content, " ", parts: 2, trim: true) do
      [_, city] -> get_weather_result(msg, city)
      _ -> Api.create_message(msg.channel_id, "Cidade não encontrada")
    end
  end

  defp get_weather_result(msg, city) do
    api_key = Application.fetch_env!(:discord_bot, :openwm_api_key)
    q = URI.encode(city)

    url =
      "https://api.openweathermap.org/data/2.5/weather?q=#{q}&appid=#{api_key}&units=metric"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        weather = Jason.decode!(body)
        temp = weather["main"]["temp"]

        Api.create_message(msg.channel_id, "Temperatura em #{city}: #{temp}°C")

      _ ->
        Api.create_message(msg.channel_id, "Cidade não encontrada")
    end
  end

  defp get_ppt_result(msg, choose) do
    options = ["pedra", "papel", "tesoura"]

    cond do
      Enum.member?(options, choose) ->
        random = Enum.random(1..100)
        result = Enum.at(options, rem(random, 3))

        case {choose, result} do
          {choose, choose} ->
            Api.create_message(msg.channel_id, "Empate")

          {"pedra", "tesoura"} ->
            Api.create_message(msg.channel_id, "Você ganhou")

          {"papel", "pedra"} ->
            Api.create_message(msg.channel_id, "Você ganhou")

          {"tesoura", "papel"} ->
            Api.create_message(msg.channel_id, "Você ganhou")

          _ ->
            Api.create_message(msg.channel_id, "Você perdeu")
        end

      true ->
        Api.create_message(msg.channel_id, "Opção invalida")
    end
  end
end
