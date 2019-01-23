# ACL

```sql
BEGIN
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
    acl => 'reportserver.xml',
    description => 'Jasper Reportserver',
    principal => 'DEVSN',
    is_grant =>  TRUE,
    privilege => 'connect');
END;
/

-- ACL dem HOST zuweisen
BEGIN
    dbms_network_acl_admin.assign_acl(
    acl => 'reportserver.xml',
    host => '*',
    lower_port => 80,
    upper_port => 8888);
END;
/

-- ACL einem weiteren User zuordnen
BEGIN
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
    acl => 'reportserver.xml',
    principal => 'DEVFW',
    is_grant => TRUE,
    privilege => 'connect');
END;
/
```