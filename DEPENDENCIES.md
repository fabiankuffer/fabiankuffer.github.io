# Abhängigkeiten aktualisieren

Diese Anleitung gilt für den portablen Jekyll-Blog mit lokalem Theme „no style, please!“, `vendor/cache/`, den Plugins `jekyll-feed`, `jekyll-seo-tag`, `jekyll-sitemap` und `jektex` sowie lokalem KaTeX-CSS und KaTeX-Schriftarten.

**Prinzip:** Das Repository enthält Quellcode, Theme, `Gemfile`, `Gemfile.lock`, den für die Build-Plattform vollständigen Gem-Cache sowie die lokal verwendeten KaTeX-Assets. Während des produktiven Builds installiert `bundle install --local` keine neuen Gems aus dem Internet. Ein Update benötigt hingegen bewusst Internetzugriff, um neue Pakete zu beschaffen.

## 1. Vor jedem Update

1. Einen eigenen Git-Branch anlegen und das funktionierende Repository sichern:

   ```bash
   git switch -c maintenance/update-dependencies
   git status --short
   ./scripts/build.sh
   ./scripts/check.sh
   ```

2. Ruby-, Bundler-, Node.js-Version und Plattform notieren:

   ```bash
   ruby --version
   bundle --version
   node --version
   uname -m
   ```

3. In `Gemfile`, `Gemfile.lock`, `.ruby-version`, `.github/workflows/deploy.yml`, `THEME_SOURCE.md` und der KaTeX-Versionsdokumentation nachsehen, was gegenwärtig verwendet wird. Die `BUNDLED WITH`-Zeile in `Gemfile.lock` hält die zuletzt zum Locken verwendete Bundler-Version fest.
4. Für die Paketauflösung **dieselbe Plattform** wie für GitHub Actions verwenden (bei `ubuntu-24.04` normalerweise Linux x86-64). Bei späteren Build-Systemen mit anderer Architektur zusätzlich deren Plattform berücksichtigen.

## 2. Jekyll und einzelne Plugins aktualisieren

Die direkte Jekyll-Abhängigkeit ist im `Gemfile` gegebenenfalls exakt festgelegt, zum Beispiel `gem "jekyll", "4.4.1"`. Für eine andere Version **zuerst diesen Eintrag bewusst ändern**. Anschließend in einer vorbereiteten, online verfügbaren Entwicklungs-/Container-Umgebung:

```bash
# Falls ein früherer Build BUNDLE_FROZEN gesetzt hat:
unset BUNDLE_FROZEN

# Vorab anzeigen, für welche Gems Updates vorhanden sind:
bundle outdated

# Nach bewusstem Anpassen des Gemfile gezielt aktualisieren:
bundle update jekyll jekyll-feed jekyll-seo-tag jekyll-sitemap jektex

# Falls noch nicht vorhanden: Zielplattform in die Lockdatei aufnehmen:
bundle lock --add-platform x86_64-linux

# Sämtliche für die Lockdatei-Plattformen benötigten Pakete ablegen:
bundle cache --all-platforms
```

**Nicht blind `bundle update` ausführen:** Ohne Paketnamen werden alle gemäß `Gemfile` erlaubten Gems aktualisiert. Für einen gezielten Sicherheitspatch nur die betroffenen Gems aktualisieren; nötige indirekte Abhängigkeiten löst Bundler dabei mit auf.

Wenn Bundler über unvereinbare Anforderungen klagt, die Versionsvorgaben der betroffenen Gems und deren Veröffentlichungsinformationen prüfen. Besonders `jektex` sowie seine Ruby- und JavaScript-Abhängigkeiten können zusätzliche Kompatibilitätsanforderungen besitzen.

## 3. KaTeX aktualisieren

KaTeX hat zwei **zusammenpassende** Teile: (a) der Renderer, der beim Jekyll-Build durch die installierte `jektex`-Version verwendet wird, und (b) das im Repository bereitgestellte CSS **einschließlich des vollständigen Font-Ordners**. Nicht nur `katex.min.css` isoliert ersetzen.

1. Zunächst nachsehen, welche KaTeX-Version die neue `jektex`-Version tatsächlich verwendet oder mit welcher Ausgabe sie kompatibel ist. Nicht automatisch davon ausgehen, dass die aktuellste KaTeX-CSS-Version passt.
2. Das passende offizielle KaTeX-Release beziehen, dessen Herkunft und Version dokumentieren und `assets/vendor/katex/katex.min.css` **und** `assets/vendor/katex/fonts/` gemeinsam ersetzen.
3. Den erforderlichen Lizenzhinweis beibehalten und gegebenenfalls aktualisieren.
4. Einen Artikel mit Inline- und Blockformeln bauen und im Browser kontrollieren: Sind alle Fonts erreichbar? Sind Glyphen, Klammern und Brüche korrekt? Erscheinen keine externen CDN-Anfragen?

Wenn der Renderer zusätzlich eigene Dateien oder Konfiguration benötigt, diese ebenfalls versionieren und den Build erneut offline testen.

## 4. Ruby, Bundler, Node.js und System aktualisieren

Diese Laufzeitumgebungen **liegen nicht automatisch in `vendor/cache/`**. Für einen reproduzierbaren Build sollten Versionen an zentralen Stellen dokumentiert werden:

- `.ruby-version` und der Ruby-Schritt in `.github/workflows/deploy.yml` auf dieselbe passende Version setzen.
- Die verwendete Bundler-Version einschließlich `Gemfile.lock` → `BUNDLED WITH` prüfen.
- Die Node.js-Version im GitHub-Workflow und in der README aktualisieren, wenn `jektex` sie für den serverseitigen Build benötigt.
- Den Linux-Runner beziehungsweise das optionale Build-Container-Image dokumentieren.

Nach einem Ruby- oder Plattformwechsel Gem-Cache und native Erweiterungen **auf der Zielplattform** neu testen. Beim Wechsel z. B. von x86-64 zu ARM können zusätzliche plattformspezifische Gems und Systembibliotheken nötig sein.

## 5. Theme aktualisieren

1. Ursprüngliches Repository und aktuell übernommenen Commit in `THEME_SOURCE.md` vergleichen.
2. Neue Theme-Dateien nur nach Vergleich mit eigenen Änderungen übernehmen; nicht einfach die lokalen `_layouts/`, `_includes/`, `_sass/` und `assets/` blind überschreiben.
3. Lokale SEO-/RSS-Tags, die Links zu `impressum.html` und `datenschutz.html` sowie den lokalen KaTeX-CSS-Pfad erneut prüfen.
4. Ursprüngliche Lizenzhinweise beibehalten und den neuen übernommenen Commit dokumentieren.

## 6. Offline-Build und Veröffentlichung testen

Nach dem Online-Update die aktualisierte `Gemfile.lock` **und** alle erforderlichen Dateien unter `vendor/cache/` gemeinsam speichern. Danach einen **frischen** Installationspfad nutzen und den Build ohne Netzwerkzugriff prüfen. Ein bloß erfolgreiches `bundle install --local` kann sonst bereits lokal installierte Gems benutzen.

Beispiel auf einem vorbereiteten Linux-x86-64-System mit Ruby, Bundler und Node.js:

```bash
rm -rf .bundle/gems
export BUNDLE_PATH="$PWD/.bundle/gems"
export BUNDLE_FROZEN=true
bundle install --local
./scripts/build.sh
./scripts/check.sh
```

Für einen wirklich isolierten Test das Repository in einer frischen, zur Zielplattform passenden Build-Umgebung **ohne Netzwerk** bereitstellen; Ruby, Node.js, Bundler und notwendige Systembibliotheken müssen darin bereits vorhanden sein. Anschließend Website im Browser prüfen: Startseite, Archiv, Artikel, Links, Feed, Sitemap, SEO-Tags und KaTeX-Schriftarten.

## 7. Rechtliche Seiten nach Infrastrukturänderungen prüfen

Bei **jedem Wechsel des Hosters, DNS-/CDN-Anbieters, Analytics-Dienstes, Kommentar-Systems oder eingebetteter Fremdinhalte** die veröffentlichte `datenschutz.md` und gegebenenfalls `impressum.md` auf tatsächliche Datenempfänger, Rechtsgrundlagen, Speicherdauer, Drittlandübermittlungen und Kontaktdaten prüfen. Eine alte GitHub-Pages-Datenschutzerklärung nicht unverändert auf einen eigenen Server übernehmen.

## 8. Commit und Rückfallmöglichkeit

```bash
git status --short
git diff -- Gemfile Gemfile.lock .ruby-version
git add Gemfile Gemfile.lock vendor/cache .ruby-version \
  .github/workflows/deploy.yml assets/vendor/katex THEME_SOURCE.md
git commit -m "Update Jekyll dependencies and local assets"
git push -u origin maintenance/update-dependencies
```

Nur Dateien zum Commit hinzufügen, die tatsächlich geändert wurden und vorhanden sind. Änderungen erst nach erfolgreichem Build und Review in `main` übernehmen. Den letzten funktionierenden Git-Commit oder ein Git-Tag für ein Rollback behalten.

## Offizielle Dokumentation

- Bundler: https://bundler.io/guides/using_bundler_in_applications.html
- Bundler und Offline-Installation: https://bundler.io/guides/faq.html
- Jekyll: https://jekyllrb.com/docs/
- KaTeX: https://katex.org/docs/
- GitHub Actions: https://docs.github.com/en/actions
