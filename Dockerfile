# Stage 1: Build the application
FROM elixir:1.12.2-alpine AS build

# Set environment variables
ENV MIX_ENV=prod

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install Node.js (required for assets)
RUN apk add --no-cache build-base npm git

# Set build directory
WORKDIR /app

# Cache and install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# Copy the rest of the application code
COPY . .

# Compile the application
RUN mix compile

# Compile assets
#RUN cd assets && npm install && npm run deploy
#RUN mix phx.digest

# Build the release
RUN mix release

# Stage 2: Create the runtime image
FROM alpine:latest AS app

# Install runtime dependencies
#RUN apk add --no-cache bash openssl

# Set work directory
WORKDIR /app

# Copy release from the build stage
COPY --from=build /app/_build/prod/rel/my_app ./

# Expose the port the app runs on
EXPOSE 4000

# Start the application
CMD ["bin/my_app", "start"]
