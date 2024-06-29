# Stage 1: Build the application
FROM hexpm/elixir:1.12.2-erlang-24.0.2-alpine-3.13.3 AS build

# Set environment variables
ENV MIX_ENV=prod
ENV LANG=C.UTF-8

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install build dependencies
RUN apk update && apk add --no-cache \
    build-base \
    git \
    npm \
    curl \
    bash \
    openssl

# Set build directory
WORKDIR /app

# Cache Elixir dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copy the rest of the application code
COPY . .

# Install npm dependencies and build assets (if any)
# Comment out if you don't have assets
# RUN cd assets && npm install && npm run deploy
# RUN mix phx.digest

# Compile the application
RUN mix compile

# Build the release
RUN mix release

# Stage 2: Create the runtime image
FROM alpine:3.13.3 AS app

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    openssl \
    ncurses-libs

# Set work directory
WORKDIR /app

# Copy the release from the build stage
COPY --from=build /app/_build/prod/rel/my_api ./

# Expose the port the app runs on
EXPOSE 4000

# Start the application
CMD ["bin/my_api", "start"]
