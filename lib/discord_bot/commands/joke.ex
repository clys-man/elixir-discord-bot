defmodule DiscordBot.Commands.Joke do
  @behaviour Nosedrum.ApplicationCommand

  def name(), do: "joke"

  @impl true
  def description(), do: "Get a programming joke"

  @impl true
  def command(interaction) do
    [
      type: {:deferred_channel_message_with_source, {&handle_request/1, [interaction]}}
    ]
  end

  defp handle_request(_interaction) do
    url =
      "https://v2.jokeapi.dev/joke/Programming"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        IO.inspect(data)

        [
          content: data["joke"]
        ]

      _ ->
        [
          content: "Error fetching joke"
        ]
    end
  end

  @impl true
  def type() do
    :slash
  end
end
