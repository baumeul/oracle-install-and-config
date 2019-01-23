DATE UND TIMESTAMP
==================



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
