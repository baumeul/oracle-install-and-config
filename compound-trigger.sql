-- Range of salary is between 4200 and 9000
select * from employees
where job_id = 'IT_PROG'
order by salary;

-- compound trigger it_prog_range verhindert salary ausserhalb range 4200 und 9000
-- before statement ermittelt zuerst die min max werte.
-- erst dann wird before each row ausgelöst!!!
create or replace trigger it_prog_range
for insert or update
on employees
when (new.job_id = 'IT_PROG')
compound trigger
v_min_it_prog number;
v_max_it_prog number;
    
    before statement is 
    begin
        select min(salary), max(salary)
        into v_min_it_prog, v_max_it_prog
        from employees
        where job_id = 'IT_PROG';
    end before statement;
    
    before each row is 
    begin
        if :new.salary not between v_min_it_prog and v_max_it_prog then
            raise_application_error(-20300, 'invalid range');
        end if;
    end before each row;

end;

insert into employees
values (900, 'ulrich', 'baumeister', 'ulrich.baumeister@me.com', null, sysdate,
'IT_PROG', 5000, 0, null, 90);

update employees
set salary = 2000
where employee_id = 107;
