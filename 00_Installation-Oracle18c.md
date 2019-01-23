# Installation Oracle-XE 18c

Installation-Oracle18c.md

## Installation

1. `$ sudo -s`

2. For Oracle Linux, the Database Preinstallation RPM is pulled automatically, proceed to the next step. For Red Hat compatible Linux distributions, download and install the **Database Preinstallation** RPM using the following:

```bash
curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm \
https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/ \
oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
yum -y localinstall oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
```

3. Access the software download page for Oracle Database RPM-based installation from **Oracle Technology Network** :
https://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html

4. **Download** the `oracle-database-xe-18c-1.0-1.x86_64.rpm` file required for performing an RPM-based installation to a directory of your choice.


5. **Install** the database software using the `yum localinstall` command.

```bash
yum -y localinstall oracle-database-xe-18c-1.0-1.x86_64.rpm
```

The Database Preinstallation RPM automatically creates Oracle installation owner and groups and sets up other kernel configuration settings as required for Oracle installations. If you plan to use job-role separation, then create the extended set of database users and groups depending on your requirements. **Check the RPM log file to review the system configuration changes**.

For example, review this file for latest changes: `/var/log/oracle-database-preinstall-18c/results/orakernel.log` .

The installation of Oracle Database software is now complete.

After successful installation, you can **delete the downloaded RPM files**, for example:

```bash
rm oracle-database-preinstall-18c-1.0-1.el6.x86_64.rpm
rm oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
rm oracle-database-xe-18c-1.0-1.x86_64.rpm
```

## Konfiguration

The configuration script creates a **container database** (`XE`) with **one pluggable database** (`XEPDB1`) and configures the **listener** at the default port (`1521`) and **Enterprise Manager Express** on port `5500`.

You can modify the configuration parameters by editing the `/etc/sysconfig/oracle—xe–18c.conf` file.

The parameters set in this file are explained in more details in the silent mode installation procedure: Performing a Silent Installation.

**To create the Oracle XE database with the default settings, perform the following steps:**

1. Execute as user `root` using `sudo`.

```bash
$ sudo -s
```

2. Run the **service configuration** script:

```bash
/etc/init.d/oracle-xe-18c configure
```

At the prompt, specify a password for the `SYS, SYSTEM`, and `PDBADMIN` administrative user accounts. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9].

## Configuration, Database Files and Logs Location

- **`/opt/oracle`** : Oracle Base. This is the root of the Oracle Database XE directory tree.
- **`/opt/oracle/product/18c/dbhomeXE`** : Oracle Home. This home is where the Oracle Database XE is installed. It contains the - directories of the Oracle Database XE executables and network files.
- **`/opt/oracle/oradata/XE`** : Database files.
- **`/opt/oracle/diag`** subdirectories : Diagnostic logs. The database alert log is /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
- **`/opt/oracle/cfgtoollogs/dbca/XE`** : Database creation logs. The XE.log file contains the results of the database creation script execution.
- **`/etc/sysconfig/oracle-xe-18c.conf`** : Configuration default parameters.
- **`/etc/init.d/oracle-xe—18c`** : Configuration and services script.

## XE Environment

After you have installed and configured Oracle Database XE, you must **set the environment** before using Oracle Database XE.

The `oraenv` and `coraenv` scripts can be used to set your environment variables.

For example, to set your environment variables in Bourne, Bash, or Korn shell without being prompted by the script:

```bash
$ export ORACLE_SID=XE
$ export ORAENV_ASK=NO
$ . /opt/oracle/product/18c/dbhomeXE/bin/oraenv

ORACLE_HOME = [] ? /opt/oracle/product/18c/dbhomeXE
The Oracle base has been set to /opt/oracle
```

## Connection

```Bash
lsnrctl status

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=dbhost.example.com)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 18.0.0.0.0 - Production
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Default Service           XE
Listener Parameter File   /opt/oracle/product/18c/dbhomeXE/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/dbhost/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=**dbhost.example.com**)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcps)(HOST=dbhost.example.com)(PORT=5500))(Security=(my_wallet_directory=/opt/oracle/admin/XE/xdb_wallet))(Presentation=HTTP)(Session=RAW))
Services Summary...
Service "77f81bd10c818208e053410cc40aef5a" has 1 instance(s).
  Instance "XE", status READY, has 1 handler(s) for this service...
Service "XE" has 1 instance(s).
  Instance "XE", status READY, has 1 handler(s) for this service...
Service "XEXDB" has 1 instance(s).
  Instance "XE", status READY, has 1 handler(s) for this service...
Service "xepdb1" has 1 instance(s).
  Instance "XE", status READY, has 1 handler(s) for this service...
The command completed successfully
```

For example, you can connect to the database from a client computer with SQL*plus using the connect identifier:

```Bash
sqlplus system@"dbhost.example/XE"
```

You can **connect to the database** using the following Easy Connect strings:

- Multitenant container database: `host[:port]`
- Pluggable database: `host[:port]/service_name`
- `XEPDB1` is the service name defined for the first PDB created by default. If your PDB has another name, you must provide the service name for that PDB.
- Specifying the port is optional when the listener is setup with the default port 1521. You must specify the port if other port number is used.

### Python

```Python
import cx_Oracle
# Connect string format: [username]/[password]@//[hostname]:[port]/[DB name]
conn = cx_Oracle.connect("system/GetStarted18c@//localhost:1521/XEPDB1")
cur = conn.cursor()
cur.execute("SELECT 'Hello World!' FROM dual")
res = cur.fetchall()
print(res)
```

## Start/Stop

**You can start and stop the database using the `/etc/init.d/oracle-xe-18c` script.**

Execute these commands as `root` using `sudo`.

```Bash
$ sudo -s
```

Run the following command to **start the listener and database**:

```bash
/etc/init.d/oracle-xe-18c start
```

Run the following command to **stop the database and the listener**:

```bash
/etc/init.d/oracle-xe-18c stop
```

Run the following command to stop and start the listener and database:

```Bash
/etc/init.d/oracle-xe-18c restart
```

**You can shut down and start the database using SQL*Plus.**

To shutdown the database, login to the oracle user with its environment variables set for access to the XE database, and issue the following SQL*Plus command:

```bash
$ sqlplus / as sysdba
SQL> SHUTDOWN IMMEDIATE
```

To start the database, issue the commands:

```sql
SQL> STARTUP
SQL> ALTER PLUGGABLE DATABASE ALL OPEN;
```

**Automating Shutdown and Startup**

Oracle recommends that you configure the system to automatically start Oracle Database when the system starts, and to automatically shut it down when the system shuts down. Automating database shutdown guards against incorrect database shutdown.

To **automate the startup and shutdown** of the listener and database, execute the following commands as `root`:

```bash
$ sudo -s
```

For Oracle Linux 7, run these commands:

```bash
systemctl daemon-reload
systemctl enable oracle-xe-18c
```

## Export/Import

### Export

To export the data from your 11.2 XE database, perform the following steps:

1. Create a directory on the local file system for the `DUMP_DIR` directory object.
2. Connect to the 11.2 XE database as user `SYS` using the `SYSDBA` privilege.
3. Create directory object `DUMP_DIR` and grant `READ` and `WRITE` privileges on the directory to the `SYSTEM` user.
```sql
sqlplus "/ AS SYSDBA"
SQL> CREATE DIRECTORY DUMP_DIR AS '/dump_folder';
SQL> GRANT READ, WRITE ON DIRECTORY DUMP_DIR TO SYSTEM;
```
4. Export data from the 11.2 XE database in the `DUMP_DIR` directory.
```bash
expdp system/system_password full=Y directory=DUMP_DIR dumpfile=DB11G.dmp logfile=expdpDB11G.log
```

### Import

**To import data to the 18c XE database, perform the following steps:**

1. Connect to 18c XE database as user `SYS` using the `SYSDBA` privilege.

2. Create directory object `DUMP_DIR` and grant `READ` and `WRITE` privileges on the directory to the `SYSTEM` user.

```bash
sqlplus / AS SYSDBA
SQL> ALTER SESSION SET CONTAINER=XEPDB1;
SQL> CREATE DIRECTORY DUMP_DIR AS '/dump_folder';
SQL> GRANT READ, WRITE ON DIRECTORY DUMP_DIR TO SYSTEM;
```

3. Import data to your 18c XE database from the dump folder.

```bash
impdp system/system_password@localhost/xepdb1 full=Y REMAP_DIRECTORY='/u01/app/oracle/oradata/XE/':'/opt/oracle/oradata/XE/XEPDB1' directory=DUMP_DIR dumpfile=DB11G.dmp logfile=impdpDB11G.log
```
Remapping the directory is necessary when you use different directory file naming conventions. The first argument of the `REMAP_DIRECTORY` parameter is the location of your 11.2 XE data files (the source) and the second argument is the location of the 18c XE data files (target).

See Oracle Database Utilities for more information about `impdp` `REMAP_DIRECTORY` parameter syntax

You can ignore the following errors:
`ORA-39083: Object type TABLESPACE:"SYSAUX" failed to create with error
ORA-31685: Object type USER:"SYS" failed due to insufficient privileges
ORA-39083: Object type PROCACT_SYSTEM failed to create with error
ORA-01917: user or role 'APEX_040000' does not exist
ORA-31684 "already exists" errors`

4. Run post database import scripts to configure Oracle Application Express (APEX).

- Download https://www.oracle.com/technetwork/developer-tools/apex/application-express/apxfix-5137274.zip and extract the `apfix.sql` script on your server.

- Copy the file `apxfix.sql` into the top level directory of the APEX source you used to upgrade APEX in your 11.2 XE database. Change your working directory to that source.

- Run `apxfix.sql` passing the schema name that owns the APEX software. For example, if you upgraded 11.2 XE to APEX 5.1.4 prior to exporting the data, provide the schema name APEX_050100 as the argument:

```bash
sqlplus / AS SYSDBA
SQL> ALTER SESSION SET CONTAINER=XEPDB1;
SQL> @apxfix.sql APEX_050100
SQL> EXIT
```

Configure the embedded PL/SQL gateway. Run the `apex_epg_config.sql` script passing the file system path to the Oracle Application Express (APEX) software. For example, if you unzipped the APEX software in /tmp:

```bash
sqlplus / AS SYSDBA
SQL> ALTER SESSION SET CONTAINER=XEPDB1;
SQL> @apex_epg_config.sql /tmp
Set the HTTP port for the embedded PL/SQL gateway. For example, to set the HTTP port to 8080:

SQL> ALTER SESSION SET CONTAINER=XEPDB1;
SQL> EXEC XDB.DBMS_XDB.SETHTTPPORT(8080);
SQL> COMMIT;
Connect to CDB$ROOT and unlock the ANONYMOUS user:

SQL> ALTER SESSION SET CONTAINER=CDB$ROOT;
SQL> ALTER USER ANONYMOUS ACCOUNT UNLOCK;
SQL> EXIT
```

## Deinstall

When you deinstall Oracle Database XE, all components, including data files, the database, and the software, are removed.

If you want to save your data files but remove the Oracle Database XE software and database, then first export the data before you deinstall.

Because the deinstallation process removes all files from the directory in which Oracle Database XE is installed, back up any files from the directory (if needed) before you deinstall. The database will no longer be operational after deinstallation.

Execute this procedure as root or with root privileges.

```bash
$ sudo -s
```

Run the following commands to deinstall Oracle Database XE:

This deletes all the Oracle Database XE data files, the listener and configuration files. After this operation, only logs and the Oracle Home software will be present.

```bash
sudo /etc/init.d/oracle-xe-18c delete
```

This removes the software. After this operation, some content under Oracle Base /opt/oracle will remain and can be deleted manually.

```bash
sudo yum remove oracle-database-xe-18c
```

Optional: If you only installed Oracle Database XE on the system and have no further Oracle Database software installed, you can also remove the Oracle Database Preinstall RPM:

```bash
sudo yum remove oracle-database-18c-preinstall
```
