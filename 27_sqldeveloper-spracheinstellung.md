# Spracheeinstellung SqlDeveloper

Diese Datei bearbeiten:

```bash
/Applications/SQLDeveloper.app/Contents/Resources/sqldeveloper/sqldeveloper/bin/sqldeveloper.conf
````

Den Parameter `AddVMOption -Duser.language=en` setzen.

```bash
IncludeConfFile ../../ide/bin/ide.conf

SetJavaHome ../../jdk

#GUI Language
AddVMOption -Duser.language=en

#Set our usage tracking URI
AddVMOption  -Dide.update.usage.servers=https://www.oracle.com/webfolder/technetwork/sqldeveloper/usage.xml

#Disable the AddinPolicyUtils
AddVMOption  -Doracle.ide.util.AddinPolicyUtils.OVERRIDE_FLAG=true

#Draw performance change
AddVMOption -Dsun.java2d.ddoffscreen=false

#font performance
AddVMOption -Dwindows.shell.font.languages=

AddVMOption -Doracle.ide.startup.features=sqldeveloper

AddJavaLibFile ../lib/oracle.sqldeveloper.homesupport.jar
AddVMOption -Doracle.ide.osgi.boot.api.OJStartupHook=oracle.dbtools.raptor.startup.HomeSupport

#Configure some JDBC settings

AddVMOption -Doracle.jdbc.mapDateToTimestamp=false
AddVMOption -Doracle.jdbc.autoCommitSpecCompliant=false

# The setting below applies to THIN driver ONLY for others set this to false.
# Refer to OracleDriver doc. for more info.
AddVMOption -Doracle.jdbc.useFetchSizeWithLongColumn=true

AddVMOption -Dsun.locale.formatasdefault=true
AddVMOption -Dorg.netbeans.CLIHandler.server=false

#Disable remote entity resolution
AddVMOption -Doracle.xdkjava.security.resolveEntityDefault=false

#Export some internal JDK APIs to reflection
AddVM9OrHigherOption --add-exports=java.base/jdk.internal.ref=ALL-UNNAMED
AddVM9OrHigherOption --add-opens=java.base/java.nio=ALL-UNNAMED
AddVM9OrHigherOption --add-opens=java.base/java.lang=java.xml.bind

# Avoid rendering exceptions on some graphics library / java / Linux combinations
AddVMOption -Dsun.java2d.xrender=false

IncludeConfFile  sqldeveloper-nondebug.conf
```
`
