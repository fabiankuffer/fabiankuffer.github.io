
#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

echo "Prüfe die generierte Website ..."

# HTML-Seiten
test -f _site/index.html
test -f _site/impressum.html
test -f _site/datenschutz.html

# RSS / Atom
test -f _site/feed.xml

# Sitemap
test -f _site/sitemap.xml

# Lokales Theme-CSS
test -f _site/assets/css/main.css

# Lokales KaTeX
test -f _site/assets/vendor/katex/katex.min.css

# KaTeX-Schriftarten
test -d _site/assets/vendor/katex/fonts

# Sind die SEO-Metadaten vorhanden?
grep -q 'rel="canonical"' _site/index.html

# Verwendet die Website noch das alte externe KaTeX-CDN?
if grep -R -q \
  'cdn.jsdelivr.net/npm/katex' \
  _site --include='*.html'; then

  echo "FEHLER: Externer KaTeX-Verweis gefunden."
  exit 1
fi

echo "Alle Prüfungen erfolgreich."
