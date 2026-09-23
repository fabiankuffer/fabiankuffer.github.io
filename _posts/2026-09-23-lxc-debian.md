---
layout: post
title: "LXC unter Debian"
date: 2026-09-23 10:00:00 +0200
description: "Infos und nützliche Kommandos für LXC unter Debian"
tags:
  - container
  - debian
  - lxc
---

## Allgmein
- **privilegierte Container**: Die User-ID 0, im Container, wird auf dem Hostsystem ebenfalls auf die User-ID 0 gemapped
- **unprivilegierte Container**: Die User-ID 0, im Container, wird auf dem Hostsystem auf einen anderen User gemapped. Hierduch kann nur auf Ressourcen zugegriffen werden, welche der User auf dem Hostsystem darf.

## API
LXC stellt eine C-API bereit, womit die Verwaltung der Container stattfinden kann.

## default.conf
In der Datei `/etc/lxc/default.conf` können Parameter hinterlegt werden, womit jeder neu erstelle Container gebaut wird.

## Netzworking
### Virtuelles Netz einrichten
In diesem Beispiel wird das virtuelle Netz als Netzwerkbrücke erstellt. Hierdurch ist die ausgehende IP-Adresse in das Netz, die IP-Adresse des Hostsystems.

1. In der Datei `/etc/default/lxc-net` muss der Inhalt `USE_LXC_BRIDGE="true"` gesetzt werden.
2. In der Datei `/etc/lxc/default.conf` muss die Zeile `lxc.network.type = empty` durch folgende Zeilen ausgetauscht werden
  ```
  lxc.net.0.type = veth
  lxc.net.0.link = lxcbr0
  lxc.net.0.flags = up
  ```
3. Zuletzt muss noch der Service `lxc-net` mit `sudo service lxc-net restart` neugestartet werden.

### Statische IP-Adresse für Container
Durch Definition einer statischen IP-Adresse für einen Container, kann bequemer auf dem Container mittels bspw. SSH zugegriffen werden.

1. Zunächst muss in der Datei `/etc/default/lxc-net` die Ziele `LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf` ergänzt werden.
2. Ebenfalls sollte in der Datei `/etc/default/lxc-net` die Zeile `LXC_DHCP_RANGE="10.0.3.2,10.0.3.100"` hinzugefügt werden, damit nicht das komplette Subnetz für DHCP-Leases verwendet wird.
2. In der Datei `/etc/lxc/dnsmasq.conf` für jeden Container folgende Zeile hinzufügen: `dhcp-host=<CONTAINER-MAC-ADDR>,<GEWÜNSCHTE-IP-ADRESSE>` (Die MAC-Adresse kann durch Sprung in den laufenden Container ermittelt werden `ip addr show`.)
3. Zusätzlich sollte die MAC-Adresse des Containers fix gesetzt werden, damit nicht die MAC-Adresse im Container nach einer Zeit geändert wird. Hierfür muss in der Containerconfig `/var/lib/lxc/<containername>/config` die Zeile `lxc.net.0.hwaddr = <CONTAINER-MAC-ADDR>` hinterlegt werden.
4. Zuletzt muss noch der Dienst `lxc-net` mittels `sudo service lxc-net restart` neugestartet werden.

Falls der Container nicht die gewünschte IP-Adresse übernimmt, sollten die vorhandenen Leases zurückgesetzt werden. Hierfür kann einfach die Datei `/var/lib/misc/dnsmasq.lxcbr0.leases` gelöscht werden. Danach muss der Dienst `lxc-net` mittels `sudo service lxc-net restart` neugestartet werden.

## Container
### Autostart einrichten
Damit der Container automatisch beim Boot des Hostsystem startet, muss in der Datei `/var/lib/lxc/<CONTAINERNAME>/config` die Zeile `lxc.start.auto = 1` hinzugefügt werden.

### Ordner des Hostsystems in einen Container mappen
Hierfür muss in der Datei `/var/lib/lxc/<CONTAINERNAME>/config` die Zeile `lxc.mount.entry = /HOST/PATH/TO/FOLDER CONTAINER/MOUNT/POINT none bind, create=dir 0 0` hinzugefügt werden.

Hier ist zu beachten, dass der Ordner im Container ein relativer Pfad sein muss. Das bedeutet, dass das erste `/` nicht angegeben werden darf.

## LXC-Befehle
### Host-Kernelkonfiguration überprüfen
Um zu überprüfen, wie der Kernel des Hostsystem kompiliert wurde, können mit `lxc-checkconfig` alle LXC-zugehörigen Kerneloptionen betrachtet werden.

### Erstellung eines privilegierten Containers
Mit `sudo lxc-create -n <CONTAINERNAME> -t download -- -d debian -r <DEBIAN-RELEASE-CODENAME> -a amd64` kann ein Container erzeugt werden. Mit `lsb_release -a` kann der aktuelle Release-Codename des Hostsystems ermittelt werden. Das Root-Dateisystem des Containers liegt unter `/var/lib/lxc/<CONTAINERNAME>/rootfs` ab.

### Container starten
`sudo lxc-start -n <CONTAINERNAME>`

Falls ein Container im Vordergrund gestartet wird, gibt es keine Möglichkeit in das aktuelle Terminalfenster zurück zu wechseln (außer den Container herunterzufahren). Ein Container wird im Vordergrund folgendermaßen gestartet `sudo lxc-start -F -n <CONTAINERNAME>`

### Container stoppen
`sudo lxc-stop -n <CONTAINERNAME>`

### Container löschen
`sudo lxc-destroy -n <CONTAINERNAME>`

### Informationen über den Container erhalten
`sudo lxc-info -n <CONTAINERNAME>`

### Status aller Container abfragen
`sudo lxc-ls --fancy`

### Zur Konsole verbinden
Wenn sich zu der Container-Konsole verbunden wird, ist dies vergleichbar mit anstecken eines Monitors. Dies erfolgt mit dem Befehl `sudo lxc-console -n <CONTAINERNAME>`

Geschlossen wird die Konsole durch die Tastenkombination `<Ctrl+a q>`

### Zu einem Container verbinden
Dies ist eher vergleichbar mit einer SSH-Sitzung. Verbunden wird mit `sudo lxc-attach -n <CONTAINERNAME> --clear-env`. Mit `--clear-env` werden keine Session-Variablen aus dem Hostsystem in die Containerlaufzeit mit übernommen.

Natürlich kann auch normal mittels SSH verbunden werden, wenn SSH im Container eingerichtet ist.