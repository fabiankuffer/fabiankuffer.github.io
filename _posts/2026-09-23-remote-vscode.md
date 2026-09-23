---
layout: post
title: "Remote-SSH VSCode"
date: 2026-09-23 11:00:00 +0200
description: "Einrichtung von Remote-SSH VS-Code"
tags:
  - Remote-SSH
  - VS-Code
---

## Allgmein
Mittels Remote-SSH für VS-Code besteht die Möglichkeit, Codeentwicklung und Ausführung auf einem externen System auszuführen bspw. einem Container. Dadurch kann sichergestellt werden, dass sich Entwicklungsumgebungen von mehreren Projekten nicht überschneiden. Zusätzlich ist zu beachten, dass auch die Extensions in VS-Code dann für jede Remote-Session nachinstalliert werden müssen.

Hierfür müssen am Hostsystem / Clientsystem und am Remotesystem ein paar Einstellungen vorgenommen werden.

Mehr Infos zum Betrieb von LXC-Container unter Debian können [hier]({% post_url 2026-09-23-lxc-debian %}) nachgelesen werden.

## Client
- Auf dem Client muss VS-Code installiert werden
- In VS-Code muss die Extension `Remote-SSH` installiert werden
- Links unten in VS-Code (`Open a Remote Window`) muss nur noch eine SSH-Verbindung auf dem Server eingerichtet werden. Hierdurch werden alle weiteren benötigten Pakete auf dem Server eingerichtet.

### SSH-Key-Erstellung
Damit nicht jedesmal beim Verbindungsaufbau mit dem Remote-Server das SSH-Passwort eingegeben werden muss, ist es sinnvoll am Server einen SSH-Key zu hinterlegen.

1. Mit `ssh-keygen -C "$(whoami)@$(uname -n)-$(date -I)"` wird ein neues SSH-Schlüsselpaar erzeugt. Mit `-C` wird ein Kommentar beim öffentlichen Schlüssel hinzugefügt. Der private und öffentliche Schlüssel liegen Dabei meist unter `~/.ssh/id_ed25519*` ab.
2. Mit `ssh-copy-id <VS-CODE-BENUTZER>@<SERVER-IP>` wird der öffentliche Schlüssel auf das Zielsystem übertragen.
3. Zuletzt sollte noch unter `~/.ssh/config` der Schlüssel hinterlegt werden, damit dieser automatisch bei einem SSH-Versuch mit dem richtigen Benutzer gefunden wird.
```
Host <ZIEL-IP-ODER-EINDEUTIGE-IDENTIFIKATION>
  Host <ZIEL-IP-ODER-DNSNAME>
  User <USERNAME-AUF-ZIELSYSTEM>
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519
```

## Server
Auf dem Server muss nur SSH installiert werden mit bspw. `sudo apt install openssh-server`.

Zusätzlich sollte noch ein spezieller VS-Code-Nutzer erstellt werden, damit nicht auf dem Remotesystem unberechtigte Zugriffe über VS-Code stattfinden können. Hierfür sind folgende Befehle auszuführen:
```
sudo useradd -m vs
passwd vs
usermod --shell /bin/bash vs
```