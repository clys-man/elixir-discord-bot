defmodule PokemonColors do
  @type_colors %{
    "normal" => 0xA8A77A,
    "fire" => 0xEE8130,
    "water" => 0x6390F0,
    "electric" => 0xF7D02C,
    "grass" => 0x7AC74C,
    "ice" => 0x96D9D6,
    "fighting" => 0xC22E28,
    "poison" => 0xA33EA1,
    "ground" => 0xE2BF65,
    "flying" => 0xA98FF3,
    "psychic" => 0xF95587,
    "bug" => 0xA6B91A,
    "rock" => 0xB6A136,
    "ghost" => 0x735797,
    "dragon" => 0x6F35FC,
    "dark" => 0x705746,
    "steel" => 0xB7B7CE,
    "fairy" => 0xD685AD
  }

  def get_color(type) do
    Map.get(@type_colors, type, 0xFFFFFF)
  end
end
