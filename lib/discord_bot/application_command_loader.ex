defmodule DiscordBot.ApplicationCommandLoader do
  require Logger

  alias Nosedrum.Storage.Dispatcher

  def load_all(guild_id) do
    get_all_command_modules()
    |> filter_application_commands()
    |> queue_commands()

    register_commands(guild_id)
  end

  defp get_all_command_modules() do
    :code.all_available()
    |> Enum.filter(fn {module, _, _} -> is_command?(module) end)
    |> Enum.map(fn {module_charlist, _, _} -> List.to_existing_atom(module_charlist) end)
  end

  defp is_command?(module_charlist) do
    List.to_string(module_charlist)
    |> String.starts_with?("Elixir.DiscordBot.Commands")
  end

  defp filter_application_commands(command_list) do
    Enum.filter(command_list, fn command ->
      case command.module_info(:attributes)[:behaviour] do
        attr when is_list(attr) -> Enum.member?(attr, Nosedrum.ApplicationCommand)
        nil -> false
      end
    end)
  end

  defp queue_commands(commands) do
    Enum.each(commands, fn command ->
      Dispatcher.queue_command(command.name(), command)
      Logger.debug("Added module #{command} as command /#{command.name()}")
    end)
  end

  defp register_commands(guild_id) do
    case Dispatcher.process_queue(guild_id) do
      {:error, {:error, error}} ->
        Logger.error(
          "Error processing commands for server #{guild_id}:\n #{inspect(error, pretty: true)}"
        )

      _ ->
        Logger.debug("Successfully registered application commands to #{guild_id}")
    end
  end
end
