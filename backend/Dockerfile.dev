FROM elixir:1.15-alpine

# Install system packages
RUN apk add --no-cache build-base git nodejs npm postgresql-client inotify-tools

# Set working directory
WORKDIR /app

# Install Elixir package tools
RUN mix local.hex --force && mix local.rebar --force

# Copy mix files first (better Docker cache)
COPY mix.exs mix.lock ./

# Install all deps for dev (default MIX_ENV is :dev)
RUN mix deps.get
RUN mix deps.compile

# Copy source code
COPY . .

# Compile the project
RUN mix compile

# Expose dev port
EXPOSE 4000

# Start dev server
CMD ["mix", "phx.server"]
