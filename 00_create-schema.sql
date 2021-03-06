-- creating a schema SN for APEX workspace
-- drop user sn cascade;
create user sn identified by "oracle" default tablespace apex temporary tablespace temp;
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