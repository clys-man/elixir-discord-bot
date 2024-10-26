defmodule DiscordBot.Commands.Movies do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description(), do: "Search for the top 20 movies based on the given category"

  @impl true
  def command(interaction) do
    [
      type: {:deferred_channel_message_with_source, {&handle_movie_search/1, [interaction]}}
    ]
  end

  defp handle_movie_search(interaction) do
    [%{name: "category", value: category}] = interaction.data.options
    api_key = Application.fetch_env!(:discord_bot, :tmdb_api_key)

    url =
      "https://api.themoviedb.org/3/movie/#{category}?api_key=#{api_key}&language=en-US&page=1"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"results" => results}} ->
            movies = Enum.take(results, 20) |> Enum.map(fn movie -> movie["title"] end)

            [
              content: "Top 20 movies in the '#{category}' category:\n" <> Enum.join(movies, "\n")
            ]

          _ ->
            [
              content: "Error parsing TMDB response."
            ]
        end

      _ ->
        [
          content: "Error fetching movies from TMDB."
        ]
    end
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "category",
        description: "Movie category (e.g., popular, top_rated, upcoming)",
        required: true
      }
    ]
  end

  @impl true
  def type() do
    :slash
  end
end
