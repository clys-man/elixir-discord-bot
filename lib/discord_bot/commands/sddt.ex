defmodule DiscordBot.Commands.SDDT do
  @behaviour Nosedrum.ApplicationCommand

  def name(), do: "sddt"

  @impl true
  def description(), do: "Should did deploy today?"

  @impl true
  def command(interaction) do
    [
      type: {:deferred_channel_message_with_source, {&handle_request/1, [interaction]}}
    ]
  end

  defp handle_request(_interaction) do
    url =
      "https://shouldideploy.today/api?tz=UTC"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = Jason.decode!(body)

        [
          content: "Should did deploy today? R: " <> data["message"]
        ]

      _ ->
        [
          content: "Error fetching data"
        ]
    end
  end

  @impl true
  def type() do
    :slash
  end
end
