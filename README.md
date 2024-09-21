# Discord Bot em Elixir

Este projeto é um bot para Discord desenvolvido em Elixir utilizando a biblioteca [Nostrum](https://github.com/Kraigie/nostrum).

## Funcionalidades

    | Em desenvolvimento

## Pré-requisitos

- [Elixir](https://elixir-lang.org/install.html)
- Token de um bot no Discord (Crie um bot em [Discord Developer Portal](https://discord.com/developers/applications))
- API Key do OpenWeatherMap (Crie uma conta em [OpenWeatherMap](https://home.openweathermap.org/users/sign_up))

## Instalação

1. Clone o repositório:

   ```bash
   git clone https://github.com/clys-man/elixir-discord-bot.git
   cd elixir-discord-bot
   ```

2. Instale as dependências:

   ```bash
   mix deps.get
   ```

3. Crie o arquivo de ambiente `.env` na raiz do projeto com as seguintes variáveis:

   ```
   DISCORD_TOKEN=seu_token_aqui
   WEATHER_API_KEY=sua_api_key_aqui
   ```

4. Execute o bot:
   ```bash
   mix run --no-halt
   ```

## Comandos Disponíveis

- [x] `!ping` - O bot responde com "pong!".
- [x] `!weather <cidade>` - Mostra a previsão do tempo para a cidade especificada.
- [x] `!ppt <escolha>` - Jogue pedra, papel, tesoura contra o bot. Exemplo: `!ppt pedra`.
