# Cronjob

```bash
vim /etc/crontab
--------------------------schnipp---------------------------------------------------------
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
0 0 * * * * oracle /u01/app/oracle/expdp.sh > /dev/null 2>&1
--------------------------schnipp---------------------------------------------------------
```

```bash
systemctl restart crond.service
```

```bash
vim vim /u01/app/oracle/expdp.sh
--------------------------schnipp---------------------------------------------------------
#!/bin/bash
current_time=$(date "+%Y%m%d%H%M%S")
filenamesn=expdpsn$current_time.dmp
filenamefw=expdpfw$current_time.dmp
expdp system/oracle SCHEMAS=SN DIRECTORY=DATA_PUMP_DIR DUMPFILE=$filenamesn
expdp system/oracle schemas=fw directory=data_pump_dir dumpfile=$filenamefw
--------------------------schnipp---------------------------------------------------------
```
