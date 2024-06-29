FROM elixir:alpine

RUN apk update

ADD . .

RUN mix local.hex --force && mix local.rebar --force
RUN mix archive.install hex phx_new --force
RUN apk update && apk add inotify-tools
RUN mix deps.get
RUN mix compile

CMD ["mix", "clean"]
CMD ["mix", "ecto.setup"]
CMD ["mix", "phx.server"]