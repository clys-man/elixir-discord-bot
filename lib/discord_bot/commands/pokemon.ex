defmodule DiscordBot.Commands.Pokemon do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description() do
    "Informações sobre um Pokémon"
  end

  @impl true
  def command(interaction) do
    [%{name: "nome", value: pokemon}] = interaction.data.options

    pokemon_info = get_pokemon_result(pokemon)

    case pokemon_info do
      {:ok, body} ->
        pokemon = Jason.decode!(body)
        id = pokemon["id"]
        name = pokemon["name"]
        types = pokemon["types"] |> Enum.map(& &1["type"]["name"]) |> Enum.join(", ")
        image = pokemon["sprites"]["front_default"]
        primary_type = pokemon["types"] |> Enum.at(0) |> Map.get("type") |> Map.get("name")
        color = PokemonColors.get_color(primary_type)
        link = "https://pokemondb.net/pokedex/#{name}"

        [
          embeds: [
            %{
              title: name,
              description: "ID: #{id}\nTipo(s): #{types}",
              image: %{url: image},
              url: link,
              color: color
            }
          ]
        ]

      {:error} ->
        [
          content: "Pokemon não encontrado"
        ]
    end
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
        name: "nome",
        description: "Nome do Pokémon",
        required: true
      }
    ]
  end

  defp get_pokemon_result(pokemon) do
    q = URI.encode(pokemon)

    url = "https://pokeapi.co/api/v2/pokemon/#{q}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      _ ->
        {:error}
    end
  end
end
