#!/bin/sh

# Initial setup
export SECRET_KEY_BASE=$(mix phx.gen.secret)
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
#$ npm run deploy --prefix ./assets
$ mix phx.digest

# Custom tasks (like DB migrations)
#$ MIX_ENV=prod mix ecto.migrate

# Finally run the server
#PORT=4001 MIX_ENV=prod mix phx.server
PORT=4001 MIX_ENV=prod elixir --erl "-detached" -S mix phx.server