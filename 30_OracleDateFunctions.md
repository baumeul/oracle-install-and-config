# Oracle Date Functions

## SQL-Developer

- Preferences > Database > NLS > Date Format: DD.MM.YYYY HH24:MI. Standard ohne Zeitangabe.

## Functions

```sql
select  sysdate,
        add_months(sysdate, 2) plus2,
        add_months(sysdate, -2) minus2,
        LAST_DAY(SYSDATE),
        MONTHS_BETWEEN(SYSDATE, date'2018-08-05') b1,
        MONTHS_BETWEEN(SYSDATE, to_date('05.12.2018','dd.mm.yyyy')) b2,
        NEXT_DAY(SYSDATE, 'SATERDAY') nd1,
        NEXT_DAY(SYSDATE, 'WED') nd2,
        TRUNC(SYSDATE) t1,
        trunc(SYSDATE, 'HH') t2,
        trunc(sysdate, 'year') t3,
        round(sysdate, 'year') round
from    dual
```

# Oracle Conversion Functions
