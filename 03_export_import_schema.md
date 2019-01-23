# Export/Import DB-Schema

## DB-User vorbereiten

Hier im Beispiel Schema `SN` und `FW`.

### Ein Schema für APEX Workspace

```sql
drop user "SN" CASCADE;
create user sn identified by "oracle" default tablespace apex temporary \
  tablespace temp;
alter user sn quota unlimited on apex;
grant unlimited tablespace to sn;
grant create session to sn;
grant create cluster to sn;
grant create dimension to sn;
grant create indextype to sn;
grant create job to sn;
grant create materialized view to sn;
grant create operator to sn;
grant create procedure to sn;
grant create sequence to sn;
grant create snapshot to sn;
grant create synonym to sn;
grant create table to sn;
grant create trigger to sn;
grant create type to sn;
grant create view to sn;

drop user "FW" CASCADE;
create user fw identified by "oracle" default tablespace apex temporary \
  tablespace temp;
alter user fw quota unlimited on apex;
grant unlimited tablespace to fw;
grant create session to fw;
grant create cluster to fw;
grant create dimension to fw;
grant create indextype to fw;
grant create job to fw;
grant create materialized view to fw;
grant create operator to fw;
grant create procedure to fw;
grant create sequence to fw;
grant create snapshot to fw;
grant create synonym to fw;
grant create table to fw;
grant create trigger to fw;
grant create type to fw;
grant create view to fw;
```

### Berechtigungen für Schema APEX als SYS setzen

```sql
$ sqlplus / as sysdba
grant execute on utl_inaddr to sn;
grant execute on utl_http to sn;
grant execute on utl_inaddr to fw;
grant execute on utl_http to fw;
```

### ACL als SYS erstellen für APEX

```sql
-- Ist bereits vorhanden
BEGIN
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
    acl => 'reportserver.xml',
    description => 'Jasper Reportserver',
    principal => 'SN',
    is_grant =>  TRUE,
    privilege => 'connect');
END;
-- ACL dem HOST zuweisen
---Ist bereits vorhanden
BEGIN
    dbms_network_acl_admin.assign_acl(
    acl => 'reportserver.xml',
    host => '*',
    lower_port => 80,
    upper_port => 8888);
END;
-- ACL einem weiteren User zuordnen
BEGIN
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
    acl => 'reportserver.xml',
    principal => 'FW',
    is_grant => TRUE,
    privilege => 'connect');
END;
BEGIN
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
    acl => 'reportserver.xml',
    principal => 'SN',
    is_grant => TRUE,
    privilege => 'connect');
END;
```

## Export

Das Werkzeug "Data Pump" kann über die Kommandozeile aufgerufen werden. Dazu
dienen die Kommandos `expdp` und `impdp`. Beide Kommandos nutzen in der
Datenbank Directories. Ein Directory in der Datenbank ist ein Kapselobjekt für
ein Verzeichnis im Filesystem des Datenbankservers.

### Alle Directories anzeigen

```bash
rlwrap sqlplus / as sysdba
```

```sql
SQL> select * from all_directories;
```

Ausgabe:
`DIRECTORY_NAME: DATA_PUMP_DIR`
`DIRECTORY_PATH: /u01/app/oracle/admin/XE/dpdump/`

### Ein Schema exportieren

Export des Schemas `SN` als User `SYSTEM`

```bash
expdp system/oracle SCHEMAS=SN DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp_sn.dmp
```

## Import

### Dumpfile kopieren

Das Exportfile `expdp_sn.dmp` vom Quellsystem auf das Zielsystem in das
Verzeichnis des `DATA_PUMP_DIR` kopieren.

#### Option 1: Import in ein Schema mit geänderten Namen

Schema `SN` (Quellsystem) in Schema `PRODSN` (Zielsystem) als User `SYSTEM`
importieren (alles in einer Zeile):

```bash
impdp system/oracle DIRECTORY=DATA_PUMP_DIR DUMPFILE=expdp_sn.dmp \
REMAP_SCHEMA=sn:devsn <TRANSFORM=SEGMENT_ATTRIBUTES:n:table>
```

#### Option 2: Import in ein Schema mit identischen Namen

Schema `SN` (Quellsystem) auf Schema `SN` (Zielsystem) als User `SYSTEM`
importieren und dabei Tablespace ändern (Die zu importierenden Tabellen lagen im
TS `APEX_2896952212612135`. Das neue TS ist aber `APEX`.)

```bash
impdp system/oracle \
DIRECTORY=DATA_PUMP_DIR \
DUMPFILE=expdp_sn.dmp \
REMAP_TABLESPACE=APEX_2896952212612135:APEX
```
