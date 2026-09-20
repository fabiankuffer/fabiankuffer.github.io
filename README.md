
# Mein Blog

Ein minimalistischer Jekyll-Blog mit dem Theme
"no style, please!".

Das Theme, alle Jekyll-Gems und die KaTeX-Assets
werden lokal im Repository verwaltet.

## Anforderungen für den Build

- Linux x86-64
- Ruby 3.3 & ruby-dev
- Bundler
- Node.js
- Gegebenenfalls Build-Werkzeuge für native Gems

Alle Ruby-Gems liegen unter vendor/cache/.

## Installation

Repository klonen und in das Projektverzeichnis
wechseln.

Anschließend:

bundle install --local

## Website erstellen

./scripts/build.sh

## Build überprüfen

./scripts/check.sh

## Ausgabe

Die fertige Website befindet sich im Ordner:

_site/

Dieser Ordner kann auf einem beliebigen
statischen Webserver veröffentlicht werden.

## Lokaler Entwicklungsserver

bundle exec jekyll serve

Anschließend im Browser öffnen:

http://localhost:4000

## Blogartikel

Alle Blogartikel liegen unter _posts/.

Dateinamen verwenden das Format:

YYYY-MM-DD-artikelname.md

## Theme

Die vollständigen Theme-Dateien liegen in:

_layouts/
_includes/
_sass/
assets/

Die Herkunft des Themes ist in
THEME_SOURCE.md dokumentiert.

## KaTeX

Das Stylesheet und die Schriftarten befinden
sich unter assets/vendor/katex/.

Die Formeln werden beim Build durch das
Jekyll-Plugin jektex gerendert.

## Plugins

- jekyll-feed
- jekyll-seo-tag
- jekyll-sitemap
- jektex

Die exakten Paketversionen stehen in
Gemfile.lock.

Die Gem-Pakete liegen unter vendor/cache/.

## Domain

Die öffentliche Domain wird in _config.yml
festgelegt.

## GitHub Pages

Der Workflow liegt unter:

.github/workflows/deploy.yml

Er ruft das universelle Build-Skript auf und
veröffentlicht anschließend den Inhalt von
_site/.

## Alternative Hosting-Anbieter

Auf einem anderen Git-Anbieter oder einem
eigenen Server muss lediglich eine passende
Build-Umgebung bereitgestellt werden.

Danach:

./scripts/build.sh

Den Inhalt von _site/ auf dem gewünschten
Webserver veröffentlichen.

Die Markdown-Dateien und Theme-Dateien müssen
für den Umzug nicht angepasst werden.

## Backup

Das komplette Git-Repository einschließlich
Gemfile.lock und vendor/cache/ sichern.

Die Domain- und DNS-Einstellungen ebenfalls
dokumentieren.

## Lizenzen

Theme:
licenses/no_style_please.txt

KaTeX:
licenses/katex.txt

Weitere Drittanbieterpakete:
Lizenzinformationen der jeweiligen Gems
beachten.
