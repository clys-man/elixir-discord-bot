defmodule DiscordBot.Commands.Ask do
  @behaviour Nosedrum.ApplicationCommand

  def name(), do: "ask"

  @impl true
  def description(), do: "Ask the AI a question"

  @impl true
  def command(interaction) do
    [
      type: {:deferred_channel_message_with_source, {&handle_prompt/1, [interaction]}}
    ]
  end

  defp handle_prompt(interaction) do
    [%{name: "message", value: message}] = interaction.data.options
    url = Application.fetch_env!(:discord_bot, :ollama_url)
    model = Application.fetch_env!(:discord_bot, :ollama_model)

    client =
      Ollama.init(
        base_url: url,
        receive_timeout: 60_000
      )

    case Ollama.completion(client,
           model: model,
           prompt: message
         ) do
      {:ok, response} ->
        [
          content: response["response"]
        ]

      _ ->
        [
          content: "Error fetching response"
        ]
    end
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "message",
        description: "The message to prompt the AI with",
        required: true
      }
    ]
  end

  @impl true
  def type() do
    :slash
  end
end
