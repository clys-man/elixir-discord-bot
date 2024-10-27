FROM elixir:1.17.2

WORKDIR /app

RUN apt-get -y update && apt-get install -y \
    ffmpeg \
    python3-pip &&\
    ln -s /usr/bin/python3 /usr/bin/python &&\
    pip install --break-system-packages --upgrade streamlink 'yt-dlp[default]'

COPY mix.exs mix.lock ./

ENV MIX_HOME=/opt/mix

RUN mix local.hex --force &&\
    mix local.rebar --force &&\
    mix deps.get

COPY . .
COPY ./docker/start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container
RUN mix compile

ENTRYPOINT [ "start-container" ]
