
#!/usr/bin/env bash

set -euo pipefail

# Zum Hauptverzeichnis des Repositories wechseln
cd "$(dirname "$0")/.."

# Installierte Gems lokal ablegen.
# Eine CI-Umgebung kann diesen Pfad überschreiben.
export BUNDLE_PATH="${BUNDLE_PATH:-$PWD/.bundle/gems}"

# Keine automatischen Änderungen an Gemfile.lock
export BUNDLE_FROZEN=true

# Produktionsumgebung
export JEKYLL_ENV=production

echo "Prüfe die Build-Umgebung ..."

ruby --version
bundle --version
node --version

echo "Installiere Gems aus dem lokalen Cache ..."

bundle install --local

echo "Erstelle die statische Website ..."

bundle exec jekyll build \
  --destination "$PWD/_site"

echo "Build erfolgreich abgeschlossen."
echo "Die Website befindet sich unter _site/."
