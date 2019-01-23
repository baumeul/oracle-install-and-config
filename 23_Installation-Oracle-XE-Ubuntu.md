# Installation Oracle-XE auf Ubuntu


## Vorbereitung

Ist ein 32- oder 64-Bit Betriebssystem installiert?

```bash
baumeul@vb06:~$ uname -i
x86_64
```

## Download

Die benötigten Softwarepakete herunterladen

```bash
baumeul@vb06:~$ sudo apt install alien libaio1 unuip bc
```

Oracle-XE-11g herunterladen

http://download.oracle.com/otn/linux/oracle11g/xe/oracle-xe-11.2.0-1.0.x86_64.rpm.zip

## Konvertieren RPM zu DEB

```bash
cd $HOME/Downloads
unzip oracle-xe-11.2.0.1.0.x86_64.rpm.zip
cd Disk1
sudo alien --scripts oracle-xe-11.2.0-1.0.x86_64.rpm
```

## Shared Memory

```bash
baumeul@vb06:~$ df -k
Dateisystem     1K-Blöcke    Benutzt  Verfügbar Verw% Eingehängt auf
udev              1994428          0    1994428    0% /dev
tmpfs              403384       1588     401796    1% /run
/dev/sda1        65791532    9659104   52760704   16% /
tmpfs             2016912          0    2016912    0% /dev/shm <== Shared Memory OK!
tmpfs                5120          4       5116    1% /run/lock
tmpfs             2016912          0    2016912    0% /sys/fs/cgroup
/dev/loop0          14976      14976          0  100% /snap/gnome-logs/45
/dev/loop1           3840       3840          0  100% /snap/gnome-system-monitor/57
/dev/loop2          89984      89984          0  100% /snap/core/5662
/dev/loop3         181376     181376          0  100% /snap/atom/206
/dev/loop4          13312      13312          0  100% /snap/gnome-characters/124
/dev/loop5         144384     144384          0  100% /snap/gnome-3-26-1604/70
/dev/loop6           2304       2304          0  100% /snap/gnome-calculator/238
/dev/loop7         475392     475392          0  100% /snap/intellij-idea-community/95
/dev/loop8          43264      43264          0  100% /snap/gtk-common-themes/701
Home           3048345992  531734936 2516611056   18% /media/psf/Home
iCloud         3048345992  531734936 2516611056   18% /media/psf/iCloud
Photo Library  3048345992  531734936 2516611056   18% /media/psf/Photo Library
Dropbox        3048345992  531734936 2516611056   18% /media/psf/Dropbox
USB03_5TB      4883332264 1934611120 2948721144   40% /media/psf/USB03_5TB
tmpfs              403380         12     403368    1% /run/user/123
tmpfs              403380         40     403340    1% /run/user/1000
```
??? Die Ausgabe bei `df -k` muß lauten `/run/shm` und nicht `/dev/shm` ???

```bash
sudo umount /dev/shm
sudo rm -rf /dev/shm
sudo mkdir /dev/shm
sudo mount -t tmpfs shmfs -o size=2048m /dev/shm
sudo vim /etc/rc2.d/S01shm_load
df -k
sudo chmod 755 /etc/rc2.d/S01shm_load
```

## Chkconfig erstellen

```bash
sudo nano /sbin/chkconfig
-----------------------schnipp---------------------------------------------
#!/bin/bash
# Oracle 11gR2 XE installer chkconfig hack for Debian by Dude
file=/etc/init.d/oracle-xe
if [[ ! `tail -n1 $file | grep INIT` ]]; then
   echo >> $file
   echo '### BEGIN INIT INFO' >> $file
   echo '# Provides:             OracleXE' >> $file
   echo '# Required-Start:       $remote_fs $syslog' >> $file
   echo '# Required-Stop:        $remote_fs $syslog' >> $file
   echo '# Default-Start:        2 3 4 5' >> $file
   echo '# Default-Stop:         0 1 6' >> $file
   echo '# Short-Description:    Oracle 11g Express Edition' >> $file
   echo '### END INIT INFO' >> $file
fi
update-rc.d oracle-xe defaults 80 01
-----------------------schnipp---------------------------------------------
```

## Berechtigungen

```bash
sudo chmod 755 /sbin/chkconfig
```

## Link für awk

```bash
sudo ln -s /usr/bin/awk /bin/awk
ls –l /bin/awk
Ausgabe: lrwxrwxrwx 1 root root 12 Nov 22 18:18 /bin/awk -> /usr/bin/awk
```



## Hostname

```bash
127.0.0.1 localhost
10.211.55.92    vb100  <=== Hier die IP-Adresse und den Hostnamen einsetzen
# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

## /etc/init.de/oracle-shm

Inhalt der Datei /etc/init.de/oracle-shm

```bash
#! /bin/sh
# /etc/init.d/oracle-shm
#
case "$1" in
 start)
  echo "Starting script /etc/init.d/oracle-shm"
  # Run only once at system startup
  if [ -e /dev/shm/.oracle-shm ]; then
   echo "/dev/shm is already mounted, nothing to do"
  else
   rm -f /dev/shm
   mkdir /dev/shm
   mount --move /run/shm /dev/shm
   mount -B /dev/shm /run/shm
   touch /dev/shm/.oracle-shm
  fi
  ;;
stop)
  echo "Stopping script /etc/init.d/oracle-shm"
  echo "Nothing to do"
  ;;
*)
  echo "Usage: /etc/init.d/oracle-shm {start|stop}"
  exit 1
  ;;
esac
```

## Startparameter

```bash
ls -l /etc/rc2.d
Ausgabe:
-rw-r--r-- 1 root root 677 Jun 15  2015 README
lrwxrwxrwx 1 root root  20 Feb  4 11:04 S01oracle-shm -> ../init.d/oracle-shm  <===
lrwxrwxrwx 1 root root  15 Feb  4 10:09 S20rsync -> ../init.d/rsync
lrwxrwxrwx 1 root root  24 Feb  4 10:09 S20screen-cleanup -> ../init.d/screen
cleanup
lrwxrwxrwx 1 root root  19 Feb  4 10:09 S70dns-clean -> ../init.d/dns-clean
lrwxrwxrwx 1 root root  18 Feb  4 10:09 S70pppd-dns -> ../init.d/pppd-dns
lrwxrwxrwx 1 root root  19 Feb  4 11:15 S80oracle-xe -> ../init.d/oracle-xe
lrwxrwxrwx 1 root root  21 Feb  4 10:09 S99grub-common -> ../init.d/grub-common
lrwxrwxrwx 1 root root  18 Feb  4 10:06 S99ondemand -> ../init.d/ondemand
lrwxrwxrwx 1 root root  18 Feb  4 10:06 S99rc.local -> ../init.d/rc.local
```

## Installation

```bash
sudo dpkg --install ./oracle-xe_11.2.0-2_amd64.deb

sudo grep /var/lock/subsys /etc/init.d/oracle-xe
    Ausgabe:
    touch /var/lock/subsys/listener
    touch /var/lock/subsys/oracle-xe
    touch /var/lock/subsys/listener
    touch /var/lock/subsys/oracle-xe
    if [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/listener
      rm -f /var/lock/subsys/oracle-xe

sudo sed -i 's,/var/lock/subsys,/var/lock,' /etc/init.d/oracle-xe
    Ausgabe:
    touch /var/lock/listener
    touch /var/lock/oracle-xe
    touch /var/lock/listener
    touch /var/lock/oracle-xe
    if [ $RETVAL -eq 0 ] && rm -f /var/lock/listener
      rm -f /var/lock/oracle-xe

sudo /etc/init.d/oracle-xe configure

sudo nano /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh
-----------------Schnipp----------------------------
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export NLS_LANG=GERMAN_GERMANY.AL32UTF8
export PATH=$ORACLE_HOME/bin:$PATH
-----------------------------------------------------
. /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh

sudo usermod -a -G dba oracle

sudo usermod -a G dba horst
```

## TOMCAT

### Java installieren
```bash
sudo apt update
sudo apt install default-jdk
```

### Tomcat User
```bash
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /u01/tomcat tomcat
```

### Download
```bash
cd /tmp
curl -O http://mirror.cc.columbia.edu/pub/software/apache/tomcat/tomcat-9/v9.0.10/bin/apache-tomcat-9.0.10.tar.gz
curl -O http://mirror.dkd.de/apache/tomcat/tomcat-9/v9.0.12/bin/apache-tomcat-9.0.12.zip
curl -O http://mirrors.ae-online.de/apache/tomcat/tomcat-9/v9.0.12/bin/apache-tomcat-9.0.12.tar.gz
```

### Installation
```bash
sudo mkdir /u01/tomcat
sudo tar xzvf apache-tomcat-9*tar.gz -C /u01/tomcat --strip-components=1
```

### Berechtigungen
```bash
cd /u01/tomcat
sudo chgrp -R tomcat /u01/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/
```

### systemd Service File
```bash
sudo apdate-java-alternatives -l
Output:
java-1.11.0-openjdk-amd64      1101       /usr/lib/jvm/java-1.11.0-openjdk-amd64  <== JAVA_HOME
java-1.8.0-openjdk-amd64       1081       /usr/lib/jvm/java-1.8.0-openjdk-amd64   <== JAVA_HOME

sudo vim /etc/systemd/system/tomcat.service
--- snipp ---
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
Environment=CATALINA_PID=/u01/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/u01/tomcat
Environment=CATALINA_BASE=/u01/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/u01/tomcat/bin/startup.sh
ExecStop=/u01/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
--- snipp ---

sudo systemctl start tomcat
sudo systemctl status tomcat
```

### Firewall
```bash
sudo ufw allow 8081

Open in web browser
http://server_domain_or_IP:8080

sudo systemctl enable tomcat
```

### Tomcat Webinterface
```bash
sudo vim /u01/tomcat/conf/tomcat-users.xml
--- snipp ---
<tomcat-users . . .>
    <user username="admin" password="password" roles="manager-gui,admin-gui"/>
</tomcat-users>
--- snipp ---

Manager app:
sudo vim /u01/tomcat/webapps/manager/META-INF/context.xml

Host Manager app:
sudo vim /u01/tomcat/webapps/host-manager/META-INF/context.xml

--- snipp ---
<Context antiResourceLocking="false" privileged="true" >
  <!--<Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />-->
</Context>
sudo systemctl restart tomcat
```

### Webinterface aufrufen
Open in web browser

```bash
http://server_domain_or_IP:8080
```

Now let's take a look at the Host Manager, accessible via the link or

```bash
http://server_domain_or_IP:8080/host-manager/html/
```




## Troubleshooting

In my one of the previous post ( http://meandmyubuntulinux.blogspot.com/2012/05/installing-oracle-11g-r2-express.html ) , I told you about steps for installation of Oracle 11g R2 express edition on Ubuntu. But I found out that many of you are facing problems in installing using the given steps. So, I came up with an idea of adding a trouble-shooter post which can enable you to have a hassle-free installation experience. Most of the time, if you followed the steps in previous post then you should be able to reach at least up to the configuration part ( Step # 6(ii) ). If you face any problem before this step then you must perform re-installation. For this do the following :

1. Enter the following command on terminal window :
sudo -s
/etc/init.d/oracle-xe stop
ps -ef | grep oracle | grep -v grep | awk '{print $2}' | xargs kill
dpkg --purge oracle-xe
rm -r /u01
rm /etc/default/oracle-xe
update-rc.d -f oracle-xe remove
2. Follow the steps given in the previous post to install the Oracle 11g XE again.
Now, once you have reached the configuration part. Do the following to avoid getting MEMORY TARGET error ( ORA-00845: MEMORY_TARGET not supported on this system ) :
sudo rm -rf /dev/shm
sudo mkdir /dev/shm
sudo mount -t tmpfs shmfs -o size=2048m /dev/shm
(here size will be the size of your RAM in MBs ).
The reason of doing all this is that on a Ubuntu system  /dev/shm is just a link to /run/shm but Oracle requires to have a seperate /dev/shm mount point.

3. Next you can proceed with the configuration and other consequent steps.

To make the change permanent do the following :

a. create a file named S01shm_load in /etc/rc2.d :

sudo vim /etc/rc2.d/S01shm_load

Now copy and paste following lines into the file :

```bash
#!/bin/sh
case "$1" in
start) mkdir /var/lock/subsys 2>/dev/null
       touch /var/lock/subsys/listener
       rm /dev/shm 2>/dev/null
       mkdir /dev/shm 2>/dev/null
       mount -t tmpfs shmfs -o size=2048m /dev/shm ;;
*) echo error
   exit 1 ;;
esac
```

b. Save the file and provide execute permissions :

         sudo chmod 755 /etc/rc2.d/S01shm_load

This will ensure that every-time you start your system, you get a working Oracle environment.
