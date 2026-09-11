#!/usr/bin/env bash
# Requires Phoenix's generator: mix archive.install hex phx_new 1.8.9 --force
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/../.." && pwd)"
consumer_parent="$(mktemp -d)"
consumer_dir="$consumer_parent/release_consumer"
trap 'rm -rf "$consumer_parent"' EXIT
cd "$repo_dir"
mix hex.build --output "$consumer_parent/slop_ui.tar"
mix phx.new "$consumer_dir" --app release_consumer --no-ecto --no-mailer --no-dashboard --no-tailwind --no-install --no-agents-md --no-version-check
python3 dev/release/check_package.py "$consumer_parent/slop_ui.tar" "$consumer_dir/deps/slop_ui"
python3 dev/release/prepare_consumer.py "$consumer_dir"
cd "$consumer_dir"
mix deps.get
MIX_ENV=test mix deps.compile
MIX_ENV=test mix compile --warnings-as-errors
mix test --warnings-as-errors
mix assets.build
test -s priv/static/assets/js/app.js
test -s priv/static/assets/css/app.css
