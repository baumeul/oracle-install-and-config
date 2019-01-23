# ORDS on Tomcat

## ASSUMPTIONS

- You have a server with Tomcat 7, 8 or 9 installed on it. In this case I used a server with [Oracle Linux 7](https://oracle-base.com/articles/linux/oracle-linux-7-installation) and used the same process to install ORDS on Tomcat 7, Tomcat 8 and [Tomcat 9](https://oracle-base.com/articles/linux/apache-tomcat-9-installation-on-linux).
- You have a database with APEX 4.2 or APEX 5.x installed. From ORDS 3.0 onward, APEX is not actually necessary, but there is some useful stuff in there, so I would always recommend it.
- The [Embedded PL/SQL Gateway](https://oracle-base.com/articles/misc/oracle-application-express-apex-5-0-installation#epg-configuration) should be configured on the APEX installation, but the HTTP port left set to the value "0".

## Multitenant : CDB or PDB Installation

When using the multitenant architecture there are several options for how to install ORDS.

For Lone-PDB installations (a CDB with one PDB) ORDS can be installed directly into the PDB. The `db.servicename` parameter will be set to the PDB service name in the properties file. This is the method I typically use as there is no additional ORDS dependency on the CDB.

If you are using multiple PDBs per CDB, you may prefer to install ORDS into the CDB to allow all PDBs to share the same connection pool. This will drastically reduce the number of database connections used compared to having a separate connection pool per PDB. In this case the db.servicename parameter will be set to the CDB service name in the properties file. From version 18.1 onward there are two ways of installing ORDS into the CDB. The recommended way is to set `cdb.common.schema=false` in the properties file, which will allow each PDB to run a different version of ORDS. Alternatively you can use `cdb.common.schema=true` in the properties file, which will mean all PDBs will have to use the same version of ORDS. Whichever option you choose, you will probably want to also use the `db.serviceNameSuffix=.your_db_domain` parameter to enable the pluggable mapping functionality.

You read more about the CDB installation options [here](https://docs.oracle.com/database/ords-18.1/AELIG/configuring-REST-data-services.htm#AELIG90195).

Remember, even though the documentation doesn't speak explicitly about installing directly into the PDB, it is a viable option for Lone-PDB instances.

## Download


Download [Oracle REST Data Services](https://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html)
.

## ORDS installation

Check the SYS user and common public users are unlocked and you know their passwords. Remember to lock the SYS user when the installation is complete.

```SQL
CONN / AS SYSDBA
ALTER USER SYS IDENTIFIED BY OraPassword1 ACCOUNT UNLOCK;
--ALTER USER SYS IDENTIFIED BY OraPassword1 ACCOUNT UNLOCK CONTAINER=ALL;

--ALTER SESSION SET CONTAINER = pdb1;
ALTER USER APEX_LISTENER IDENTIFIED BY OraPassword1 ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY OraPassword1 ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER IDENTIFIED BY OraPassword1 ACCOUNT UNLOCK;

-- The next one will fail if you've never installed ORDS before. Ignore errors.
ALTER USER ORDS_PUBLIC_USER IDENTIFIED BY OraPassword1 ACCOUNT UNLOCK;
```

Unzip the ORDS distribution. In this case we are doing this as the "tomcat" user on the server.

```bash
# su - tomcat
$ mkdir /u01/ords
$ cd /u01/ords
$ unzip /tmp/ords.17.4.0.348.21.07.zip
```
Make a directory to hold the configuration.

```bash
$ mkdir -p /u01/ords/conf
```

> If you have any failures during the installation, remember to delete the contents of this directory before trying again.

Edit the "`/u01/ords/params/ords_params.properties`" file provided with the ORDS software, setting the appropriate parameters for your installation. In this case my file contents were as follows.

```bash
db.hostname=ol7-122.localdomain
db.port=1521
db.servicename=pdb1
#db.sid=
# Next 2 lines for CDB installations only.
#cdb.common.schema=false
#db.serviceNameSuffix=.your_db_domain
db.username=APEX_PUBLIC_USER
db.password=OraPassword1
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=APEX
schema.tablespace.temp=TEMP
standalone.mode=false
# Next 3 lines for standalone mode only.
#standalone.use.https=true
#standalone.http.port=8080
#standalone.static.images=/home/oracle/apex/images
user.apex.listener.password=OraPassword1
user.apex.restpublic.password=OraPassword1
user.public.password=OraPassword1
user.tablespace.default=APEX
user.tablespace.temp=TEMP
sys.user=SYS
sys.password=OraPassword1
```

>  If you need to restart the installation for any reason, remember of clear down the config directory and check the contents of the "/u01/ords/params/ords_params.properties" file before you restart the installation. Having password entries in this file from a failed installation can cause problems.

Use the "ords.war" file to specify the configuration directory using the following command. The file name "ords.war" will result in a URL containing "/ords/". If you want a different URL, rename the WAR file accordingly. In this article I will use the original name.

```bash
$ $JAVA_HOME/bin/java -jar ords.war configdir /u01/ords/conf
Dec 17, 2017 8:50:19 AM
INFO: Set config.dir to /u01/ords/conf in: /u01/ords/ords.war
```

Configure ORDS using the following command. This is the equivalent of specifying the "install simple" command line parameters. If you've entered the parameters correctly in the parameter file there should be no prompts. If some parameters are missing or incorrect you will be prompted for a response.

```bash
$JAVA_HOME/bin/java -jar ords.war

Retrieving information.
Dec 17, 2017 8:50:59 AM
INFO: Updated configurations: defaults, apex, apex_pu, apex_al, apex_rt
Installing Oracle REST Data Services version 17.4.0.348.21.07
... Log file written to /u01/ords/logs/ords_install_core_2017-12-17_085059_00767.log
... Verified database prerequisites
... Created Oracle REST Data Services schema
... Created Oracle REST Data Services proxy user
... Granted privileges to Oracle REST Data Services
... Created Oracle REST Data Services database objects
... Log file written to /u01/ords/logs/ords_install_datamodel_2017-12-17_085224_00812.log
... Log file written to /u01/ords/logs/ords_install_apex_2017-12-17_085234_00725.log
Completed installation for Oracle REST Data Services version 17.4.0.348.21.07. Elapsed time: 00:01:40.123
```

Lock the SYS user.
```sql
ALTER USER SYS ACCOUNT LOCK;
```

## Tomcat Deployment

Copy the APEX images to the Tomcat "webapps" directory.

```bash
$ mkdir $CATALINA_HOME/webapps/i/
$ cp -R /tmp/apex/images/* $CATALINA_HOME/webapps/i/
```

Copy the "`ords.wa`r" file to the Tomcat "`webapps`" directory.

```bash
$ cd /u01/ords
$ cp ords.war $CATALINA_HOME/webapps/
```

ORDS should now be accessible using the following type of URL.

```html
http://<server-name>:<port>/ords/
http://ol7.localdomain:8080/ords/
```

## Starting/Stopping ORDS Under Tomcat

ORDS is started or stopped by starting or stopping the Tomcat instance it is deployed to. Assuming you have the CATALINA_HOME environment variable set correctly, the following commands should be used.

```bash
$ $CATALINA_HOME/bin/startup.sh
$ $CATALINA_HOME/bin/shutdown.sh
```

## ORDS Validate

You can validate/fix the current ORDS installation using the validate option.

```bash
$JAVA_HOME/bin/java -jar ords.war validate
Enter the name of the database server [ol7-122.localdomain]:
Enter the database listen port [1521]:
Enter the database service name [pdb1]:
Requires SYS AS SYSDBA to verify Oracle REST Data Services schema.

Enter the database password for SYS AS SYSDBA:
Confirm password:

Retrieving information.

Oracle REST Data Services will be validated.
Validating Oracle REST Data Services schema version 18.2.0.r1831332
... Log file written to /u01/asi_test/ords/logs/ords_validate_core_2018-08-07_160549_00215.log
Completed validating Oracle REST Data Services version 18.2.0.r1831332.  Elapsed time: 00:00:06.898
```

## Manual ORDS Uninstall

In recent versions you can use the following command to uninstall ORDS and provide the information when prompted.

```bash
# su - tomcat
$ cd /u01/ords
$ $JAVA_HOME/bin/java -jar ords.war uninstall
Enter the name of the database server [ol7-122.localdomain]:
Enter the database listen port [1521]:
Enter 1 to specify the database service name, or 2 to specify the database SID [1]:
Enter the database service name [pdb1]:
Requires SYS AS SYSDBA to verify Oracle REST Data Services schema.

Enter the database password for SYS AS SYSDBA:
Confirm password:

Retrieving information.
Uninstalling Oracle REST Data Services
... Log file written to /u01/ords/logs/ords_uninstall_core_2018-06-14_155123_00142.log
Completed uninstall for Oracle REST Data Services. Elapsed time: 00:00:10.876
```

In older versions of ORDS you had to extract scripts to perform the uninstall in the following way.

```bash
su - tomcat
cd /u01/ords
$JAVA_HOME/bin/java -jar ords.war ords-scripts --scriptdir /tmp
```

Perform the uninstall from the "oracle" user using the following commands.

```bash
su - oracle
cd /tmp/scripts/uninstall/core/

sqlplus sys@pdb1 as sysdba

@ords_manual_uninstall /tmp/scripts/logs
```
