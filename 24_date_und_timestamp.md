DATE UND TIMESTAMP
==================

DATE
----
```sql
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
select sysdate, dump(sysdate) as data_bytes from dual;
-- sysdate: 2018-11-19 16:25:26
-- dump(sysdate): Typ=13 Len=8: 226,7,11,19,16,25,26,0
```

TIMESTAMP
---------

```sql
alter session set nls_timestamp_format='YYYY-MM-DD HH24:MI:SS.FF6';
select localtimestamp, dump(localtimestamp) ts_bytes from dual;
-- 2018-11-19 16:06:06.510226
-- 2018-11-19 16:08:33.666251
```

TIMESTAMP OHNE DATUM
--------------------

```sql
alter session set nls_timestamp_format='HH24:MI:SS.FF6';
select localtimestamp, dump(localtimestamp) ts_bytes from dual;
-- Zeit1: 16:10:35.134523
-- Zeit2: 16:11:23.473316
```

MIT ZEIT RECHNEN
----------------

```sql
select to_timestamp('16:11:23.473316', 'HH24:MI:SS.FF6') as t2
     , to_timestamp('16:10:35.134523', 'HH24:MI:SS.FF6') as t1
     , to_timestamp('16:11:23.473316', 'HH24:MI:SS.FF6') -
       to_timestamp('16:10:35.134523', 'HH24:MI:SS.FF6') as delta
from dual;
```

ANZAHL DER SEKUNDEN ZWISCHEN ZWEI ZEITPUNKTEN
---------------------------------------------

```sql
SELECT abs( EXTRACT( SECOND FROM interval_difference )
          + EXTRACT( MINUTE FROM interval_difference ) * 60
          + EXTRACT( HOUR FROM interval_difference ) * 60 * 60
          + EXTRACT( DAY FROM interval_difference ) * 60 * 60 * 24
            )
  FROM ( SELECT systimestamp - (systimestamp - 1) AS interval_difference
           FROM dual )
```

EINE FUNKTION ZUR BERECHNUNG DER ZEITDIFFERENZ
----------------------------------------------

```sql
CREATE OR REPLACE FUNCTION intervalToSeconds(
     p_Minuend TIMESTAMP ,
     p_Subtrahend TIMESTAMP ) RETURN NUMBER IS

v_Difference INTERVAL DAY TO SECOND ;

v_Seconds NUMBER ;

BEGIN

v_Difference := p_Minuend - p_Subtrahend ;

SELECT EXTRACT( DAY    FROM v_Difference ) * 86400
     + EXTRACT( HOUR   FROM v_Difference ) *  3600
     + EXTRACT( MINUTE FROM v_Difference ) *    60
     + EXTRACT( SECOND FROM v_Difference )
  INTO
    v_Seconds
  FROM DUAL ;

  RETURN v_Seconds ;

END intervalToSeconds ;
```

DIE FUNKTION `intervalToSeconds` AUFRUFEN
-----------------------------------------

```sql
declare
    v_t1 bm_time.tm_t1%type;
    v_t2 bm_time.tm_t2%type;
begin
    select tm_t1, tm_t2 into v_t1, v_t2
      from bm_time
      where tm_versuch = 'SCHLEIFE';
    dbms_output.put_line(intervalToSeconds(p_minuend    => v_t2,
                                           p_subtrahend => v_t1));
end;
-- Ausgabe: 1,121135
```

```sql
declare
  v_von date;
  v_bis date;
  v_tag date;
begin
  v_tag := to_date('16.06.18','dd.mm.yy') + 1;

  v_von := to_date('17.06.18','dd.mm.yy');
  v_bis := to_date('21.06.18','dd.mm.yy');

  dbms_output.put_line('Buchungsdatum ist: '|| v_tag);

  if v_tag between v_von and v_bis then
    dbms_output.put_line('Schon besetzt');
  else
    dbms_output.put_line('Frei');
  end if;
end;
```
