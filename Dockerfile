FROM elixir:latest

WORKDIR /app

COPY . /app

RUN mix deps.get

RUN mix compile

# Start the application
CMD ["bin/my_app", "start"]
