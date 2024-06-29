FROM elixir:latest

RUN mix deps.get

COPY . /app

WORKDIR /app

EXPOSE 4000

CMD ["mix", "phoenix.server"]
