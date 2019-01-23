# Installing CX Oracle for Python

## Instant Client Download for macOS

Everyone needs either _Basic_ or _Basic lite_, and most users will want
_SQL*Plus_ and the _SDK_.

Instant Client Downloads for macOS (Intel x86):

<http://www.oracle.com/technetwork/topics/intel-macsoft-096467.html>

	instantclient-basic-$VERSION-macosx-x64.zip

_instantclient-basic-macos.x64-12.2.0.1.0-2.zip_

	instantclient-sdk-$VERSION-macosx-x64.zip

_instantclient-sdk-macos.x64-12.2.0.1.0-2.zip_

## Prepare works

Edit `~/.zshrc` or `~/.bashrc`, add following:

	# Oracle instantclient
	export ORACLE_HOME=/usr/local/share/oracle/instantclient_12_1
	export DYLD_LIBRARY_PATH=/usr/local/share/oracle/instantclient_12_1
	#export TNS_ADMIN=/usr/local/share/oracle/instantclient_12_1/network/admin
	export CLASSPATH=$CLASSPATH:$ORACLE_HOME
	export NLS_LANG="GERMAN_GERMANY.AL32UTF8"
	export VERSION=12.1.0.2.0
	export ARCH=x86_64
	$ source ~/.zshrc

## Create a directory

	mkdir -p /usr/local/share/oracle

## Unpack both files to that directory

	unzip instantclient-basic-macos.x64-12.2.0.1.0-2.zip -d /usr/local/share/oracle
	unzip instantclient-sdk-macos.x64-12.2.0.1.0-2.zip -d /usr/local/share/oracle

All files will  now be located in `/usr/local/share/oracle/instantclient_12_2`

## Create sym links
Symlinks in dieser Version bereits vorhanden.

		#	ln -s libclntsh.dylib.12.1 libclntsh.dylib
		#	ln -s libocci.dylib.12.1 libocci.dylib

Pycharm verlangt aber diesen Link:

		mkdir ~/lib
		ln -s /usr/local/share/oracle/instantclient_12_2/libclntsh.dylib.12.1 ~/lib/

## Install with pip

	env ARCHFLAGS="-arch $ARCH" pip3 install cx_Oracle

## Problem

	$ python3
	>>> import cx_Oracle
	>>> db = cx_Oracle.connect('user', 'passwd', 'host:1521/xe')
	Traceback (most recent call last):
	File "<stdin>", line 1, in <module>
	cx_Oracle.DatabaseError: ORA-21561: OID generation failed

## Solution

	$ hostname
	Ulrichs-iMac.fritz.box

Edit `/etc/hosts`

	127.0.0.1 Ulrichs-iMac.fritz.box

## Test

	$ python3
	>>> import cx_Oracle
	>>> db = cx_Oracle.connect('immo', '[passwd]', 'vb08:1521/xe')
	>>> db.version
	'11.2.0.2.0'
