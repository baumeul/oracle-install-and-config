# Installation

## Konfiguration

```{.bash .numberLines .startFrom="10"}
Specify a password to be used for database
accounts. Oracle recommends that the password
entered should be at least 8 characters in length
```

```bash
[root@nc01 oracle]# /etc/init.d/oracle-xe-18c configure
Specify a password to be used for database accounts. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9]. Note that the same password will be used for SYS, SYSTEM and PDBADMIN accounts:
Confirm the password:
Configuring Oracle Listener.
Listener configuration succeeded.
Configuring Oracle Database XE.
SYS-Benutzerkennwort eingeben:
*****
SYSTEM-Benutzerkennwort eingeben:
*******
PDBADMIN-Benutzerkennwort eingeben:
*******
DB-Vorgang vorbereiten
7 % abgeschlossen
Datenbankdateien werden kopiert
29 % abgeschlossen
Oracle-Instanz wird erstellt und gestartet
30 % abgeschlossen
31 % abgeschlossen
34 % abgeschlossen
38 % abgeschlossen
41 % abgeschlossen
43 % abgeschlossen
Erstellen von Datenbank wird abgeschlossen
47 % abgeschlossen
50 % abgeschlossen
Integrierbare Datenbanken werden erstellt
54 % abgeschlossen
71 % abgeschlossen
Aktionen nach Abschluss der Konfiguration werden ausgeführt
93 % abgeschlossen
Benutzerdefinierte Skripts werden ausgeführt
100 % abgeschlossen
Erstellen der Datenbank abgeschlossen. Einzelheiten finden Sie in den Logdateien in:
 /opt/oracle/cfgtoollogs/dbca/XE.
Datenbankinformationen:
Globaler Datenbankname:XE
System-ID (SID):XE
Weitere Einzelheiten finden Sie in der Logdatei "/opt/oracle/cfgtoollogs/dbca/XE/XE.log".

Connect to Oracle Database using one of the connect strings:
     Pluggable database: nc01/XEPDB1
     Multitenant container database: nc01
Use https://localhost:5500/em to access Oracle Enterprise Manager for Oracle Database XE
[root@nc01 oracle]#
```

## Connect

```bash
➜  ~ /Applications/sqlcl/bin/sql sys/oracle@nc01:1521/XE as sysdba

SQLcl: Release 18.3 Production auf Mi. Okt. 31 16:50:08 2018

Copyright (c) 1982, 2018, Oracle. All rights reserved. Alle Rechte vorbehalten.

Verbunden mit:
Oracle Database 18c Express Edition Release 18.0.0.0.0 - Production
Version 18.4.0.0.0
```

```sql
SQL> select sysdate from dual;

SYSDATE
--------
31.10.18

SQL>
```
