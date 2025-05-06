# Use Elixir Alpine as base image
FROM elixir:1.15-alpine

# Install OS dependencies
RUN apk add --no-cache build-base git nodejs npm postgresql-client

# Set working directory
WORKDIR /app

# Install Elixir build tools
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy Elixir project files first (to leverage Docker layer caching)
COPY mix.exs mix.lock ./

# Install Elixir deps (this layer caches unless deps change)
RUN mix deps.get

# Copy the rest of the application
COPY . .

# Ensure deps are up to date in case Git deps changed
RUN mix deps.get --only prod && \
    mix compile

# Expose the Phoenix app port (if needed)
EXPOSE 4000

# Start the Phoenix server
CMD ["mix", "phx.server"]
