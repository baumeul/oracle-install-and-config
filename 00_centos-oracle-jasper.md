# CentOS 7.2 - Oracle 18 - APEX 18c - Jasperserver - Tomcat - ORDS - httpd

## DOWNLOADS

- **Oracle Datenbank**
  - Oracle Database 18c Express Edition for  Linux x64 + 
  - Oracle Database Preinstall RPM for RHEL and CentOS Release 7: https://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index-083047.html

- **Oracle Apex**
  - Oracle APEX Release 18.2 All Languages: https://www.oracle.com/technetwork/developer-tools/apex/downloads/index.html

- **Oracle ORDS**
  - Oracle REST Data Services 18.4: https://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html

- **Tomcat**
  - Apache Tomcat 9.0.14 Core: https://tomcat.apache.org/download-90.cgi

- **JasperReports**
  - JasperReports Server CE TIB_js-jrs-cp_7.1.0_linux_x86_64.run: https://community.jaspersoft.com/project/jasperreports-server/releases
  - Jaspersoft Studio 6.6.0 CE: https://community.jaspersoft.com/project/jaspersoft-studio/releases

- **CentOS**
  - CentOS-7-x86_64-Minimal-1804: http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso


## CENTOS INSTALLIEREN

Here is the first tip - it is a good idea to set up a *network connection* first, bacause it'll help a bit with the further installation. Choose *Network & Host Name* in the menu, toggle the connection On and then click the Configure... button in the right bottom corner, here choose IPv4 Settings tab and now you're able to choose **DHCP** or add a **static IP address** if needed.

Now the most interesting part - _disk partitioning_. Click the Installation Destination menu item and select the desired hard disk. If you have only one, it is checked by default. Now I'd recommend you to select I will configure partitioning in order to be able to partition the disk manually. Click Done then.

On the next screen you're invited to choose your partitioning schema. I prefer clicking the link _**Click here to create them automatically to pre-create**_ the schema. When you're done, you see a screen like this one.

The size of the partitions depend on the amount of RAM in your computer and on the size of the hard drive respectively. As you can see, by default CentOS 7 offers you a standard partition type for /boot and an LVM-based root partition, both of xfs filesystem. I'm quite ok with this, but if you like, you can choose a standard partition type for your root partition, or a filesystem, different to xfs (for example, ext4, which is also very reliable). Advantage of using LVM-based partitions is the fact they could be easily extended with another physical drive (your logical drive will be the same) or even shrinked (though not on xfs filesystem, for this you will need, for example, ext4). However, LVM is not supported on a boot partition. The only things that I changed in this standard partitioning schema were the name of the Volume Group and the swap size.

>Note the fact that Oracle Database XE requires **at least 2GB** of swap size and recommends the swap size doubles the size of the RAM available.

### PARALLELS TOOLS INSTALLIEREN

Im Menü ***Parallels Tools installieren*** wählen

```{.bash .numberLines}
sudo yum install epel-release -y
sudo yum install gcc kernel-devel-$(uname -r)
sudo yum insstall kernel-headers-$(uname -r) make dkms
ssh root@vbnn
mkdir /media/cdrom
mount /dev/disk/by-label/Parallels\\x20Tools /media/cdrom
/media/cdrom/install
```

Für VirtualBox lautet der mount-Befehl:

    mount /dev/disk/by-label/VBox_GAs_5.2.22 /media/cdrom

und der Aufruf des Installers:

    /media/cdrom/VBoxLinuxAdditions.run

### VORBEREITUNG DER INSTALLATION

Up to 12 GB of user data
Up to 2 GB of database RAM
Up to 2 CPU threads
Up to 3 Pluggable Databases

#### SWAP

Oracle verlangt mindestens 2 GB Swap Space.

```bash
sudo swapon -s
Ausgabe:
Filename        Type      Size    Used  Priority
/dev/dm-1       partition 6713340 0     -1
```

Die VM verfügt über 6 GB Swap. Falls kein Swap oder zuwenig vorhanden ist:

```{.bash .numberLines}
sudo dd if=/dev/zero of=/swapfile count=8192 bs=1M  # 8 GB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo vi /etc/fstab
--- schnipp ---
/swapfile none swap 0 0
swap  swap  defaults  0 0
--- schnipp ---
sudo swapon -s # Kontrolle
sudo sysctl vm.swapiness=10
sudo vi /usr/lib/sysctl.d/00-system-conf
--- schnipp ---
vm.swappiness = 10 # Letzte Zeile
--- schnipp ---
```

#### UPDATE OS

```bash
ssh root@vbnn
yum upgrade -y
```

#### JAVA UND TOOLS INSTALLIEREN

```{.bash .numberLines}
yum install -y java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64
yum install -y net-tools htop iotop iftop wget mc
yum install -y nano vim libaio bc flex unzip
yum install -y rlwrap
```

Alternativ das Oracle-JDK herunterladen und installieren:

    sudo yum localinstall -y <oracle-jdk.rpm>

A few words about the packages installed:

- _java-1.8.0-openjdk.x86_64_ and _java-1.8.0-openjdk-devel.x86_64_ are Java 8 Development Kit packages, which are needed for Tomcat and ORDS to operate.

    >Installing Java from official repository using yum should set all the needed environment variables. But you can check it by executing the command java -version and if it works, everything is ok. But if not, then correctly set the $PATH and $JAVA_HOME variables.

- **`mc` - Midnight Commander** - a really powerful file manager similar to Norton Commander or FAR Manager.
- **`net-tools.x86_64`** - useful and customary network utilites such as ifconfig and netstat. The thing is in CentOS 7 they replaced these usual utilites with ip and ss commands, so to be able to use ifconfig it should be installed manually.
- **`htop`** - a very good alternative to standard top utility. It is much more powerful and can be flexibly configured.
- **`vim`** - Enhanced vi Editor.

#### FTP BZW. COPY INSTALLATIONSDATEIEN

Auf dem Server: `mkdir /root/install`.

Auf dem Client:

```bash
scp apex_5.1.4.zip root@192.168.178.50:/tmp
scp oracle-xe-11.2.0-1.0.x86_64.rpm.zip root@192.168.178.50:/tmp
scp TIB_js-jrs-cp_6.4.2_linux_x86_64.run root@192.168.178.50:/tmp
```

*Die folgenden Schritte bis zum Abschnitt Oracle-XE stammen teilweise von dsavenko.me <http://dsavenko.me/oracledb-apex-ords-tomcat-httpd-centos7-all-in-one-guide-introduction>*

#### NETWORK TIME SYNCHRONIZATION

There's an utility called chrony for this purpose in the minimal CentOS installation:

```bash
systemctl start chronyd
systemctl enable chronyd
```

#### DISABLING SELINUX ON CENTOS7

Now, we need to disable selinux. Its configuration and usage is a topic for a different series of blog posts, so here we'll just omit all this. Change the value `SELINUX=enforcing` to **`SELINUX=disabled`**. Then save the config file. After doing this, execute `setenforce 0`:

```bash
vim /etc/sysconfig/selinux
setenforce 0
```

#### FIREWALL CENTOS7

CentOS 7 uses firewalld as a main firewall service, which is an additional abstraction level above iptables. In many other guides you could see people disabling it and returning to use iptables directly. I don't know why, maybe because it always hard to pick up something new. And so, I tried, and really liked firewalld ease of configuration (especially in comparison to iptables if you're new to it).
To configure the firewall, we are going to do these things:

1. Add a new service called oracle-db.
2. Set the new service description and add the port to it.
3. Enable such services as http, https and oracle-xe for the default zone public.
4. Reload firewall list of rules on-the-fly.

Hilfreiche Kommandos

```{.bash .numberLines}
ip a s -- IP-Adresse anzeigen
rpm -qa | grep firewalld 		# Ist Firewall installiert?
rpm -qc firewalld 				# Konfigurationsdatei für firewalld anzeigen
systemctl status firewalld 		# Läuft die Firewall?
firewall-cmd state 				# dto.
firewall-cmd --list-all 		# Was ist erlaubt?
firewall-cmd --get-zones 		# Zeige Zonen
firewall-cmd --get-services 	# Zeige Services

# KONFIGURATION ORACLE/HTTP/JASPER
firewall-cmd --permanent --new-service=oracle-db
firewall-cmd --permanent --new-service=jasper
firewall-cmd --permanent --service=oracle-db --set-short="Oracle Database Listener" --add-port=1521/tcp
firewall-cmd --permanent --service=jasper --set-short="Jasper Reportserver" --add-port=8081/tcp
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-service=oracle-db
firewall-cmd --permanent --zone=public --add-service=jasper
firewall-cmd --reload
```

#### PORTS DIREKT SETZEN

    firewall-cmd --add-port=1521/tcp
    firewall-cmd --add-port=8081/tcp

#### TOMCAT/ APACHE HTTPD INSTALLATION

    yum install tomcat httpd -y
    systemctl start tomcat
    systemctl enable tomcat
    systemctl start httpd
    systemctl enable httpd

That's it! By now both Tomcat and httpd should work on your system and should listen ports 8080 and 80 respectively on your server. Note the fact that we intentionally didn't open port 8080 on our server, because we are not going to use it. Instead, httpd will reverse proxy all requests to Tomcat using AJP protocol listener on port 8009.

>You even may disable the HTTP connector on port 8080 in Tomcat's server.xml config (this is very optional). I will not tell you how to do this, consider it an excercise. Do not forget to restart the Tomcat service afterwards in case you already opened your mc file manager.

## ORACLE-XE18C INSTALLATION

    ssh root@vbnn
    # 18c
    yum localinstall -y oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
    yum localinstall -y oracle-database-xe-18c-1.0-1.x86_64.rpm


Notice that I used yum to install the local packages instead of rpm. This will
enable us to use all the power of yum in the future if needed (for example, to
remove a package with its dependencies).

The user `oracle` and the group `oinstall` (not dba as it was previously) are
created during the package installation, so we do not need to create them
explicitly. Also, the default user environment is created during the set up
process (so we do not have to do it expicitly as it was previously). If you
like, you can set a password for this user by invoking passwd oracle command.
This user is the owner of the `/opt/oracle` directory where the Oracle Database
is located and this must stay unchanged.

Now, when the packages are installed and the user is set up, you need to run
the initial database configuration script:

    /etc/init.d/oracle-xe-18c configure


**Es erfolgt diese Ausgabe:**

    Specify a password to be used for database accounts. Oracle recommends that the
    password entered should be at least 8 characters in length, contain at least 1
    uppercase character, 1 lower case character and 1 digit [0-9]. Note that the
    same password will be used for SYS, SYSTEM and PDBADMIN accounts:
    Confirm the password:
    Configuring Oracle Listener.
    Listener configuration succeeded.
    Configuring Oracle Database XE.
    SYS-Benutzerkennwort eingeben:
    *******
    SYSTEM-Benutzerkennwort eingeben:
    ******
    PDBADMIN-Benutzerkennwort eingeben:
    ******
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
         Pluggable database: vb04/XEPDB1
         Multitenant container database: vb04
    Use https://localhost:5500/em to access Oracle Enterprise Manager for Oracle Database XE.


### SETTING THE ORACLE ENVIRONMENT VARIABLES

Jetzt die _Oracle Database Environment Variablen_ setzen, so das User komfortabel zugreifen können. Zusätzlich setze ich zwei praktische Aliase:

```{.bash .numberLines}
echo '# setting oracle database environment variables and aliases' >> /etc/profile.d/oraenv.sh
echo 'ORACLE_SID=XE' >> /etc/profile.d/oraenv.sh
echo 'ORAENV_ASK=NO' >> /etc/profile.d/oraenv.sh
echo '. /usr/local/bin/oraenv -s' >> /etc/profile.d/oraenv.sh
echo 'alias sqlplus="rlwrap sqlplus"' >> /etc/profile.d/oraenv.sh
echo 'alias rman="rlwrap rman"' >> /etc/profile.d/oraenv.sh
. /etc/profile.d/oraenv.sh
```

Automatischer Start für _Oracle Database 18c XE service_:

    systemctl enable oracle-xe-18c

>CentOS7 nutzt `systemd` anstatt `sysconfig` um system services zu starten. Deshalb die Services via `sysctl` starten/stoppen.

### CONNECTING TO ORACLE-DB

```{.sql .numberLines}
su - oracle
lsnrctl status
-- Container DB (CDB)
sqlplus system/oracle@vbnn/XE

-- Pluggable DB (PDB)
sqlplus system/oracle@vbnn/XEPDB1 # Pluggable DB

sqlplus /nolog

-- connect to the database
SQL> connect sys as sysdba

-- basic query to check if everything works
SQL> select * from dual;

-- check components and their versions
SQL> select comp_id, version, status from dba_registry;

SQL> exit
```

That is it! By now we have succesfully installed the XE instance and it is up
and running.

>Note that since 12c Oracle Database has multitenant architecture, which means
there could be several pluggable databases and one multitenant container
database. By default, the XEPDB1 pluggable database is created during the
installation of XE.

To make it easier to connect to the pluggable database, I recommend editing of
tnsnames.ora file and add there a new connection descriptor that we are going
to use:

    sudo vim /opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora


Add this record there below the standard XE record:

    PDB1 =
     (DESCRIPTION =
       (ADDRESS = (PROTOCOL = TCP)(HOST = vb04.shared)(PORT = 1521))
       (CONNECT_DATA =
         (SERVER = DEDICATED)
         (SERVICE_NAME = XEPDB1)
       )
    )


And save the changes.

### START/STOP

**You can start and stop the database using the `/etc/init.d/oracle-xe-18c` script.**

Execute these commands as `root` using `sudo`.

    $ sudo -s

Run the following command to **start the listener and database**:

    /etc/init.d/oracle-xe-18c start

Run the following command to **stop the database and the listener**:

    /etc/init.d/oracle-xe-18c stop

Run the following command to stop and start the listener and database:

    /etc/init.d/oracle-xe-18c restart

**You can shut down and start the database using SQL*Plus.**

To shutdown the database, login to the oracle user with its environment variables set for access to the XE database, and issue the following SQL*Plus command:

    $ sqlplus / as sysdba
    SQL> SHUTDOWN IMMEDIATE

To start the database, issue the commands:

    SQL> STARTUP
    SQL> ALTER PLUGGABLE DATABASE ALL OPEN;


**Automating Shutdown and Startup**

Oracle recommends that you configure the system to automatically start Oracle Database when the system starts, and to automatically shut it down when the system shuts down. Automating database shutdown guards against incorrect database shutdown.

To **automate the startup and shutdown** of the listener and database, execute the following commands as `root`:

    $ sudo -s

## INSTALLATION OF CURRENT VERSION OF APEX 18C

Previously installation process of the latest version of Oracle Application
Express (also known as APEX) consisted of deinstalling of the previous version
and then installing of a new version. In 18c Oracle stopped to ship the Express
Edition of their RDBMS with APEX preinstalled. So the step to deinstall the
preinstalled version od APEX is not needed anymore.

Another difference will be in the fact that we are going to utilize the
multitenant architecture of the 18c XE and will be installing our environment
into the pluggable database. This enables us to potentially have different
versions of APEX installed into different PDBs.

So now the installation process roughly consists of unzipping of the downloaded archive with the freshest version of APEX, connecting to the PDB, running a few installation scripts and then copying static files to your web server directory.

So let's get it started. Change your directory back to `/root/install`, unzip the APEX archive and make the user oracle the owner of the directory. Considering we are installing the 18.2 version of APEX, it would look like this:

```{.bash .numberLines}
ssh root@vbnn
cd /root/install # hier liegt das zip-Archiv
mkdir -p /opt/oracle/apex
unzip apex_18.2_en.zip -d /opt/oracle
chown -R oracle:oinstall /opt/oracle/apex
su - oracle
cd /opt/apex/apex
ssqlplus sys/oracle@localhost/xepdb1 as sysdba
```

### INSTALLING A FULL DEVELOPMENT ENVIRONMENT

```{.sql .numberLines}
SQL> @apexins.sql SYSAUX SYSAUX TEMP /i/
SQL> select version from dba_registry where comp_id='APEX';
VERSION
------------------------------
18.2.0.00.12
-- creating an instance administrator user and setting a password to them
SQL> @apxchpwd.sql
-- configure "RESTful Services" (needed to ORDS to serve workspaces and applications static files)
SQL> @apex_rest_config.sql
-- Install German Language
SQL> @load_trans GERMAN
-- disable embedded PL/SQL gateways
SQL> exec dbms_xdb.sethttpport(0);
SQL> exec dbms_xdb.setftpport(0);
-- unlocking and setting up APEX public user, this is needed by ORDS to connect to APEX engine
SQL> alter user apex_public_user account unlock;
SQL> alter user apex_public_user identified by "oracle";
-- add ACL to enable outgoing connections for APEX internal user
-- this is needed for the APEX_EXEC and APEX_WEB_SERVICE APIs to function properly
-- change it for a more strict policy if needed
SQL> begin
     dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs$ace_type(
            privilege_list => xs$name_list('connect'),
            principal_name => 'APEX_180200',
            principal_type => xs_acl.ptype_db))
        ;
end;
/
-- now disconnect from the database
SQL> exit
```

#### COPY APEX STATIC FILES (IMAGES, STYLESHEETS, JS FILES AND SO ON) TO THE WEB SERVER DIRECTORY

```{.bash .numberLines}
ssh root@vbnn
mkdir -p /var/www/apex/images
cp -a /opt/oracle/apex/images/. /var/www/apex/images
```

Now we finished with the _Application Express_ installation.

#### SESSIONTIMEOUT

Als `admin` im `internal` Workspace

* Maximale Sessiondauer in Sekunden = 28.800 (Standardwert, 8 Stunden)
* Maximale Session-Leerlaufzeit in Sekunden = 10.800 (Standardwert 3.660 = Eine Stunde)


## INSTALLATION OF ORDS

The _Oracle Rest Data Services_ (ORDS) installation consists of unzipping the
downloaded archive, running the configuration command, and then deploying the
`ords.war` file into the Tomcat webapps folder.

Change back your directory to `/root` and unzip the ORDS archive:

```{.bash .numberLines}
ssh root@vbnn
cd /root/install
mkdir -p /opt/oracle/ords
```


Run the ORDS configuration command before deployment. Choose the advanced mode -
in this case the installation process will be interactive:

```{.bash .numberLines}
unzip ords-18.*.zip -d /opt/oracle/ords
cd /opt/oracle/ords
java -jar ords.war install advanced
```

**HINWEIS: Es darf keine "_einfaches_" Passwort (z.B. oracle) vewendet werden.**

When prompted for ORDS configuration directory (the first question),
enter **`config`**. Then provide the connection info to your pluggable database
(specify XEPDB1 for the service name).

>Note that we specified `XEPDB1` here, not `PDB1`, because ORDS needs the service
name, not your TNSNAMES entry by default to connect to your database. However,
when you complete the installation, you can change ORDS settings to use TNS as
the connection method. Find out how in the official documentation.

>Note that "RESTful Services" are required by APEX 5 and above, so enable this
by specifying passwords for the APEX_LISTENER and APEX_REST_PUBLIC_USER when
prompted.

The Tomcat user (created as part of Tomcat install) must have write access to
the /config/ folder:

    chown -R tomcat:tomcat /opt/oracle/ords/config

Now it's high time to deploy ORDS to Tomcat application server. Copy the
`ords.war` into the Tomcat webapps directory for this (and we will restart
the Tomcat service later):

    cp -a /opt/oracle/ords/ords.war /usr/share/tomcat/webapps/

Done! We succeded in installing of ORDS and deploying it to Tomcat by now.
Only one step is left.

Problem in der Art:

**„There are issues with the configuration of the Static Files in your environment. Please consult the _Configuring Static File Support_ section in the Application Express Installation Guide.“**

habe ich behoben, indem ich erneut `@apex_rest_config.sql` habe laufen lassen.

**Installation validieren**

    java -jar ords.war validate [--database <dbname>]


**ORDS löschen/reinstallieren**

    java -jar ords.war uninstall

### Configuration of Apache httpd to map HTTP-requests to ORDS

Create the `10-apex.conf` file in the `/etc/httpd/conf.d/` directory

The last, but not the least step in this part of the guide is to configure
_Apache httpd_ to map HTTP-requests to _ORDS_ and therefore _APEX_ engine.

For this, add a custom httpd configuration file. By default, every `.conf` file
placed in the `etc/httpd/conf.d/` directory is read by _httpd_ as an additional
configuration file to the main `/etc/httpd/conf/httpd.conf` config file.

>Note that these additional config files are read and processed by httpd in
alphabetical order, so name your custom config accordingly if you use multiple
config files.

So, let's create the `10-apex.conf` file in the `etc/httpd/conf.d/` directory with
the contents as below:

        vim /etc/httpd/conf.d/10-apex.conf


```{.bash .numberLines}
--- schnipp ---
# additional apache httpd configuration for apex requests proxying
# add this to the end of /etc/httpd/conf/httpd.conf
# or put it in a separate file such as /etc/httpd/conf.d/10-apex.conf

# forward ORDS requests to tomcat
<VirtualHost *:80>
    # uncomment the lines below if you plan to serve different domains
    # on this web server, don't forget to change the domain name
    # ServerName yourdomain.tld
    # ServerAlias www.yourdomain.tld

    # alias for apex image files
    Alias "/i" "/var/www/apex/images/"

    # uncomment the line below if you want
    # to redirect traffic to ORDS from root path
    # RedirectMatch permanent "^/$" "/ords"

    # proxy ORDS requests to tomcat
    ProxyRequests off
    <Location "/ords">
        ProxyPass "ajp://localhost:8009/ords"
        ProxyPassReverse "ajp://localhost:8009/ords"
    </Location>
</VirtualHost>
--- schnipp ---
```

Now you are ready to save the configuration file and restart the services.

**Restarting the services**

    systemctl restart httpd
    systemctl restart tomcat

And finally, you're ready to access APEX from your web browser using a link
like <http://yourdomain.tld/ords> (or <http://yourdomain.tld> in case you switched
on force redirection), where yourdomain.tld is the domain name or the IP-address
of your server.

You're ready to access APEX from your web browser using a link like <http://vbnn/ords>

## APACHE HTTPD TWEAKS

### DISABLE THE DEFAULT WELCOME PAGE

    rm -rf /etc/httpd/conf.d/welcome.conf


### ADD AN ADDITIONAL CONFIGURATION file 0-extra.conf in the etc/httpd/conf.d/

```{.bash .numberLines}
vim /etc/httpd/conf.d/0-extra.conf
------------schnipp--------------------
# additional apache httpd configuration
# add this to the end of /etc/httpd/conf/httpd.conf
# or put it in a separate file such as /etc/httpd/conf.d/0-extra.conf
# disable sensitive version info
ServerSignature Off
ServerTokens Prod
# enable compression of static content
<IfModule deflate_module>
     SetOutputFilter DEFLATE
     AddOutputFilterByType DEFLATE text/plain text/html text/xml text/css text/javascript
</IfModule>
# enable client caching of static content
<IfModule expires_module>
    ExpiresActive On
    ExpiresByType image/gif "access plus 7 days"
    ExpiresByType image/jpeg "access plus 7 days"
    ExpiresByType image/png "access plus 7 days"
    ExpiresByType text/css "access plus 7 days"
    ExpiresByType text/javascript "access plus 7 days"
    ExpiresByType application/javascript "access plus 7 days"
    ExpiresByType application/x-javascript "access plus 7 days"
</IfModule>
------------schnipp--------------------
```

## TOMCAT TWEAKS

### EDIT THE TOMCAT SERVICE SYSTEMD UNIT FILE

```{.bash .numberLines}
vim /usr/lib/systemd/system/tomcat.service
------------schnipp-----------------------------------
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target oracle-xe.service
Wants=oracle-xe.service
------------schnipp-----------------------------------
systemctl daemon-reload
```

## ORACLE XE TWEAKS

    -- connect to the database
    $ rlwrap / as sysdba


### ALTERING THE DEFAULT PASSWORD POLICY

```sql
-- altering the default password policy (by default passwords will expire
-- in 180 days)
SQL> alter profile default limit password_life_time unlimited;
```

### SOME RECOMMENDED VALUES FOR THE PARAMETERS

```{.sql .numberLines}
SQL> alter system set sessions=250 scope=spfile;
SQL> alter system set processes=200 scope=spfile;
SQL> alter system set memory_target=1G scope=spfile;
SQL> alter system set memory_max_target=1G scope=spfile;
SQL> alter system set job_queue_processes=100 scope=spfile;
```

Die Oracle Developer Days VM is so konfiguriert:

```
sessions=472
processes=300
memory_target=0
memory_max_target=0
job_queue_processes=4000
```

### CREATING A TABLESPACE FOR OUR APEX WORKSPACES

```sql
SQL> create tablespace apex datafile '/opt/oracle/oradata/XE/apex.dbf'
size 128M reuse autoextend on next 8M maxsize unlimited;
```

### CREATING A SCHEMA FOR OUR APEX WORKSPACES

```{.sql .numberLines}
drop user "SN" CASCADE;
create user sn identified by "oracle"
  default tablespace apex temporary tablespace temp;
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
```

```sql
-- restart database
SQL> shutdown immediate
SQL> startup
```

## ORDS TWEAKS

**THE DEFAULT CONNECTION POOL SETTINGS IN THE ORDS CONFIGURATION ARE TOO SMALL**

    vim /u01/ords/config/ords/conf/apex.xml

```{.xml .numberLines}
-------------------------schnipp-------------------------
<entry key="jdbc.InitialLimit">10</entry>
<entry key="jdbc.MinLimit">10</entry>
<entry key="jdbc.MaxLimit">60</entry>
-------------------------schnipp-------------------------
```

    systemctl restart tomcat

## ANMELDUNG EINES NORMALEN BENUTZER AM WS

### PL/SQL-Gateway

<http://185.233.105.124:8080/apex/f?p=101:1>

### ORDS
<http://185.233.105.124/ords/f?p=101:1>


## JASPER REPORTSERVER INSTALLATION

**Anmerkung ORDS/Jasperserver**: ORDS/Oracle läuft mit Tomcat auf Port 8080.
Jasperserver (Standardinstallation) läuft mit eigenem Tomcat auf Port 8081.
Ports müssen in Firewall freigeben sein: `firewall-cmd --add-port=8081/tcp`
für Jasperserver.

```{.bash .numberLines}
chmod 755 TIB_js-jrs-cp_6.4.2_linux_x86_64.run
./TIB_js-jrs-cp_6.4.2_linux_x86_64.run    # Die Defaultwerte verwenden
cd /tmp
/opt/jasperreports-server-cp-6.4.2/ctlscript.sh start
```

### Firewall

```{.bash .numberLines}
firewall-cmd --permanent --new-service=jasper
firewall-cmd --permanent --service=jasper \
    --set-short="Jasper Reportserver" --add-port=8081/tcp
firewall-cmd --permanent --zone=public --add-service=jasper
firewall-cmd --reload
```

### Zugriff testen

<http://vbnn:8081/jasperserver>
_jasperadmin/jasperadmin_

```{.bash .numberLines}
cd /usr/lib/firewalld/services/
cp postgresql.xml jasper.xml
vim jasper.xml
```

```{.xml .numberLines}
------------------schnipp---------------------------------------
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Jasper</short>
  <description>Jasper Reportsserver</description>
  <port protocol="tcp" port="8081"/>
</service>
------------------schnipp---------------------------------------
```

    firewall-cmd --reload

### Data Source hinzufügen

*Data Sources > Resource hinzufügen > Datenquelle*

Parameter           Wert
------------------  -------------------------------------
Typ                 **JDBC-Datenquelle**  
JDBC-Treiber        **Oracle (oracle.jdbc.OracleDriver)**
Host                **localhost**  
Port                **1521**   
Dienst              **XE**  
URL                 **jdbc:oracle:thin:@localhost:1521:XE**  
Benutzername        **sn/oracle**

Ggf. Treiber hinzufügen ... > _Datei auswählen_ > _iMac_ >   
_Library_ > _JDBC_ > _ojdbc8.jar_ > _Hochladen_

**Workspace SN** (StecoNatura) erstellen  
**Workspace FW** (Ferienwohnung) erstellen

### Berechtigungen für APEX

```{.sql .numberLines}
$ sqlplus / as sysdba
SQL> grant execute on utl_inaddr to sn;
SQL> grant execute on utl_inaddr to fw;
SQL> grant execute on utl_http to sn;
SQL> grant execute on utl_http to fw;
```

### ACL als SYS erstellen für APEX

```{.sql .numberLines}
BEGIN
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
    acl => 'reportserver.xml',
    description => 'Jasper Reportserver',
    principal => 'SN',
    is_grant =>  TRUE,
    privilege => 'connect');
END;

-- ACL dem HOST zuweisen
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
```

## JASPERSOFT STUDIO CE 6.5.1

**Repository Explorer**

**DATA ADAPTER HINZUFÜGEN**

*Data Adapters > Create Data Adapter > Database JDBC Connection*

Parameter                  Wert
-----------------------    -----------------------------------
Name                       **sn@vb01** bzw. **fw@vb01**  
JDBC Driver                **oracle.jdbc.driver.OracleDriver**  
JDBC Url                   **jdbc:oracle:thin:@vb01:1521:xe**  
Username:                  **sn** bzw. **fw**  
Password:                  xxxx  
-----------------------    ------------------------------------

Table: Data Adapter hinzufügen

**SERVER HINZUFÜGEN**

| Parameter                     | Wert                                |
|:----------                    |:------------------------------------|
| Name:                         | **JasperReports Server**            |
| URL:                          | **<http://vb01:8081/jasperserver>** |  
| Acount                        |                                     |
| Organization: blank           |                                     |   
| User:                         | **jasperadmin**                     |
| Password:                     | **jasperadmin**                     |
| Advanced Settings:            |                                     |
| Authentication:               | **Password**                        |
| JasperReports Libray Version: | **Same version as server**          |
| Workspace Folder:             | **/SteccoNatura**                   |
| Local:                        | **Deutsch(Deutschland)**            |  
| Time Zone:                    | **Europe/Berlin**                   |

Table: Server hinzufügen
