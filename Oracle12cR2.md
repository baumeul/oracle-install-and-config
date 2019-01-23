# Oracle 12cR2, CentOS, Parallels

## Datenbank hochfahren, Listener starten, Tomcat starten

#### 1. Starte Parallels vb17

#### 2. Als root einloggen:
`vb17 login: root`

#### 3. Als oracle anmelden:
`[root@vb17 ~]# su - oracle`

#### 4. Listener starten:
`[oracle@vb17 ~]$ lsnrctl start`

#### 5. SQL*Plus starten:
`[oracle@vb17 ~]$ sqlplus / as sysdba`

#### 6. Datenbank hochfahren:
`SQL> startup`

#### 7. SQL*Plus beenden:
`SQL> exit`

#### 8. Als oracle abmelden:
`[oracle@vb17 ~]$ exit`

#### 9. Tomcat starten:
`[root@vb17 ~]# /opt/tomcat9/bin/startup.sh`

#### 10. APEX aufrufen:
http://vb17:8088/ords/
Workspace: `immo_verwalter`
User: `admin`
Password: `oracle`

#### 11. Immoverwaltung NRW App starten:
`App.Builder > Immoverwaltung NRW > Anwendung ausführen`
Benutzername: `admin`
Kennwort: `oracle`

#### 12. CSV-Dateien importieren:
`CSV Files Upload`
Dateien auswählen
`Projekte > Immoverwaltung > csv > 2017 > 2017-12-31`
Alle Dateien markieren > `Auswählen`
`hochladen`