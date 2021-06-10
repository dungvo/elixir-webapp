#!/bin/sh
# Initial setup
export SECRET_KEY_BASE=$(mix phx.gen.secret)
mix deps.get --only prod
MIX_ENV=prod mix compile

# Install / update  JavaScript dependencies
#$ npm install --prefix ./assets

# Compile assets
#npm run deploy --prefix ./assets
MIX_ENV=prod mix phx.digest

MIX_ENV=prod mix release