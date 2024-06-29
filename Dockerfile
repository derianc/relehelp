FROM elixir:latest

RUN mix compile

COPY . /app

WORKDIR /app

EXPOSE 4000

CMD ["mix", "phoenix.server"]
