# APEX and ORDS up and running in....2 steps

In January 2017, I had a meeting with Dr. Sriram Birudavolu from Hyderabad.  He got my attention when he said he would love to start a 1000-person APEX Meetup group in Hyderabad (gotta love aggressive goals!).  However, he spent much of December and January just trying to figure out how to get APEX installed, configured and running.  He won't profess to be an expert, but he's exactly the type of person we want to enable.  He was correct in saying that if a potential customer struggles to get APEX installed, we've already lost.

Recently, Gerald Venzl asked for some assistance in creating a Docker image for APEX.  His goal was to create an APEX Docker image on top of the base Oracle Database Docker image.  He knows a lot about Docker, but he won't claim to be an expert in APEX.  He wanted something that is scriptable and can result in APEX being installed, configured and up and running, along with ORDS, in as few steps as possible.  A "silent install", if you please. This was the final bit of motivation I needed for this blog post and video.

While the installation documentation is complete and detailed, it's also lengthy and sometimes confusing - especially for the new person.  Thus, I wanted to provide the simplest set of instructions with as few steps as possible to get APEX installed, configured and up and running, along with ORDS configured and up and running.  It can be done in two steps.  That's right, two.  While I explain the individual steps executed from SQL*Plus in detail below, you can combine all of these SQL commands into a single SQL script.  I prefer the name "hookmeup.sql".

Download and unzip APEX http://www.oracle.com/technetwork/developer-tools/apex/downloads/index.html
cd to apex directory
Start SQL*Plus and ensure you are connecting to your PDB and not to the "root" of the container database (APEX should not be installed at all):

    sqlplus sys/your_password@localhost/your_pdb as sysdba @apexins sysaux sysaux temp /i/

Unlock the `APEX_PUBLIC_USER` account and set the password:

    alter user apex_public_user identified by oracle account unlock;

Create the APEX Instance Administration user and set the password:

    begin
        apex_util.set_security_group_id( 10 );
        apex_util.create_user(
            p_user_name => 'ADMIN',
            p_email_address => 'your@emailaddress.com',
            p_web_password => 'oracle',
            p_developer_privs => 'ADMIN' );
        apex_util.set_security_group_id( null );
        commit;
    end;
    /

Run APEX REST configuration, and set the passwords of `APEX_REST_PUBLIC_USER` and `APEX_LISTENER`:

    @apex_rest_config_core.sql oracle oracle

Create a network ACE for APEX (this is used when consuming Web services or sending outbound mail):

    declare
        l_acl_path varchar2(4000);
        l_apex_schema varchar2(100);
    begin
        for c1 in (select schema
                     from sys.dba_registry
                    where comp_id = 'APEX') loop
            l_apex_schema := c1.schema;
        end loop;
        sys.dbms_network_acl_admin.append_host_ace(
            host => '*',
            ace => xs$ace_type(privilege_list => xs$name_list('connect'),
            principal_name => l_apex_schema,
            principal_type => xs_acl.ptype_db));
        commit;
    end;
    /

Exit SQL*Plus.  Download and unzip ORDS http://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html
cd to the directory where you unzipped ORDS (ensure that ords.war is in your current directory)
Copy the following into the file params/ords_params.properties and replace the contents with the text below (Note:  this is the file ords_params.properties in the "params" subdirectory - a subdirectory of your current working directory):

    db.hostname=localhost
    db.port=1521
    # CUSTOMIZE db.servicename
    db.servicename=your_pdb
    db.username=APEX_PUBLIC_USER
    db.password=oracle
    migrate.apex.rest=false
    plsql.gateway.add=true
    rest.services.apex.add=true
    rest.services.ords.add=true
    schema.tablespace.default=SYSAUX
    schema.tablespace.temp=TEMP
    standalone.mode=TRUE
    standalone.http.port=8080
    standalone.use.https=false
    # CUSTOMIZE standalone.static.images to point to the directory
    # containing the images directory of your APEX distribution
    standalone.static.images=/home/oracle/apex/images
    user.apex.listener.password=oracle
    user.apex.restpublic.password=oracle
    user.public.password=oracle
    user.tablespace.default=SYSAUX
    user.tablespace.temp=TEMP

Configure and start `ORDS` in stand-alone mode.  You'll be prompted for the `SYS` username and `SYS` password:

    java -Dconfig.dir=/your_ords_configuration_directory -jar ords.war install simple --preserveParamFile

That's it!!  You should now be able to go to `http://localhost:8080/ords/`, and login with:

    Workspace: internal
    Username:  admin
    Password:  oracle
