FROM elixir:1.15-alpine

# Install OS dependencies
RUN apk add --no-cache build-base git nodejs npm postgresql-client inotify-tools

WORKDIR /app

# Install Elixir build tools
RUN mix local.hex --force && \
    mix local.rebar --force

# Set development environment
ENV MIX_ENV=dev

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy the rest of the application
COPY . .

# Compile the application
RUN mix compile

EXPOSE 4000

# Use mix phx.server for hot reloading in dev
CMD ["mix", "phx.server"]