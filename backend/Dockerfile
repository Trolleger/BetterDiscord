FROM elixir:1.15-alpine

RUN apk add --no-cache build-base git nodejs npm postgresql-client inotify-tools

WORKDIR /app

# Install Hex and Rebar (mix build tools)
RUN mix local.hex --force && mix local.rebar --force

# Copy ONLY mix.exs and mix.lock first (key for caching and locking)
COPY mix.exs mix.lock ./

# Fetch and compile dependencies respecting the lock file
RUN mix deps.get --only dev
RUN mix deps.compile

# Now copy the rest of the source code
COPY . .

# Compile your app
RUN mix compile

RUN mkdir -p /app/_build /app/deps /app/tmp && chmod -R 777 /app/_build /app/deps /app/tmp

EXPOSE 4000

CMD ["mix", "phx.server"]
