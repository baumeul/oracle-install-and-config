# CENTOS7 - PARTITIONIERUNG NETCUP

## Rettungssystem

**Anmerkung: Beim Installieren eines neuen Image für CentOS (netcup) hat man die
*Wahl zwischen drei Optionen: Eine Option lautet "*Installation mit großer
*Partition für das Betriebssystem*". Dabei wird der root-Partition die maximal
*zur Verfügung stehende Kapazität zur Verfügung gestellt. Swap hat 3 GB. Eine
*weitere Partitionierung ist also nicht notwendig.**

Um die Partitionierung der Festplatte zu ändern müssen Sie das System im
Rettungssystem hochfahren. Ändern Sie hierzu die Boot-Reihenfolge des
KVM-Servers so, dass zuerst über das Netzwerk gebootet wird. Diese Einstellungen
nehmen Sie im VCP im Menü `Einstellungen > Boot Reihenfolge` vor. Den Button
`Netzwerk` nach oben ziehen und abschließend `Speichern`. Daraufhin aktivieren
Sie das Rettungssystem im Menü `Medien > Rettungssystem > Das Rettungssystem
aktivieren`.

Nach der Aktivierung erscheint die Information *Rettungssystem is aktiviert* und
ein Root-Kennwort: `PB8CtnYspRwmhT8` (Beispiel).

Nach einem erfolgreichen *Reboot in das Rettungssystem*, können Sie sich per SSH
zum root Benutzer verbinden. Nun verbinden Sie sich mit den angezeigten
temporären Passwort mit dem Rettungssystem: `Steuerung > Garantierter Neustart`.
Der Server wird gestoppt und neu gestartet.

Jetzt mit `ssh root@nc01`und dem temporären Passwort verbinden. Evtl. muss
vorher die Datei `.ssh/known_hosts` editiert werden. Die Zeile mit `nc01`
löschen und erneuter Verbindungsversuch. Sie sind jetzt im Rettungssystem des
Servers.

## Welche Partitionen gibt es

```bash
[root@v22018064928168134 ~]# ls -l /dev/sd*
brw-rw---- 1 root disk 8, 0  3. Jul 12:30 /dev/sda
brw-rw---- 1 root disk 8, 1  3. Jul 12:30 /dev/sda1
brw-rw---- 1 root disk 8, 2  3. Jul 12:30 /dev/sda2
brw-rw---- 1 root disk 8, 3  3. Jul 12:30 /dev/sda3
brw-rw---- 1 root disk 8, 4  3. Jul 12:33 /dev/sda4
```
Es gibt vier Partitionen /dev/sda1 bis /dev/sda4.

## Welche Partitionen werden genutzt

```bash
[root@v22018064928168134 ~]# df
Dateisystem    1K-Blöcke Benutzt Verfügbar Verw% Eingehängt auf
/dev/sda3        7090680 5621372   1086076   84% /
devtmpfs         3994160       0   3994160    0% /dev
tmpfs            4004852  607624   3397228   16% /dev/shm
tmpfs            4004852    8764   3996088    1% /run
tmpfs            4004852       0   4004852    0% /sys/fs/cgroup
tmpfs             800972       0    800972    0% /run/user/1000
tmpfs             800972       0    800972    0% /run/user/0
-- Nur /dev/sda3 ist gemountet.
```
Nur eine Partition (/dev/sda3) ist gemountet.

## Partition erstellen (falls erwünscht)

Partition muss nicht erstellt werden, da /dev/sda1, /dev/sda2 und /dev/sda4
existieren, aber nicht gemountet sind. Also nur mounten einer vorhandenen
Partition.

```bash
[root@v22018064928168134 ~]# fdisk /dev/sda
WARNING: fdisk GPT support is currently new, and therefore in an experimental
phase. Use at your own discretion. Welcome to fdisk (util-linux 2.23.2). Changes
will remain in memory only, until you decide to write them. Be careful before
using the write command. Befehl (m für Hilfe):

-- p eingeben

Befehl (m für Hilfe): p
Disk /dev/sda: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = Sektoren of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: gpt
Disk identifier: E86F9609-BF7F-4DA6-84D0-E43B2C7E679F
#         Start          End    Size  Type            Name
 1         2048         4095      1M  BIOS boot       BIOS
 2         4096      6295551      3G  Linux swap      primary
 3      6295552     20969471      7G  Linux filesyste primary
```

## File System erstellen

```bash
/sbin/mkfs.ext3 -L /opt /dev/sda4
```

## Partition mounten

-- Wir nutzen die Partition /dev/sda4 für das Filesystem /opt

```bash
mount /dev/sda4 /opt
```

### Eintrag in /etc/fstab

`LABEL=/opt	/opt	ext3	defaults	1	2`

Abschliessend Bootreihenfolge wieder auf Festplatte setzen und Reboot.
