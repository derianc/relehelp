# Stage 1: Build the application
FROM hexpm/elixir:1.13.0-erlang-24.1.5-alpine-3.14.2 AS build

# Set environment variables
ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    REPLACE_OS_VARS=true

# Install necessary build tools
RUN apk update && apk add --no-cache \
    build-base \
    git \
    npm \
    nodejs \
    bash

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build directory
WORKDIR /app

# Cache Elixir deps
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copy the rest of the application code
COPY . .

# Build the application
#RUN mix compile

# Install npm dependencies and build assets
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

# Build the release
RUN mix release

# Stage 2: Prepare the runtime image
FROM alpine:3.14

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    openssl \
    ncurses-libs

# Set environment variables
ENV LANG=C.UTF-8 \
    REPLACE_OS_VARS=true \
    MIX_ENV=prod \
    PORT=4000 \
    HOME=/app

# Set work directory
WORKDIR /app

# Copy release from the build stage
COPY --from=build /app/_build/prod/rel/my_app ./

# Expose the port the app runs on
EXPOSE 4000

# Start the application
CMD ["bin/my_app", "start"]
