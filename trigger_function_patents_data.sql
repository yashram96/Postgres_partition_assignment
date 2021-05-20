
create or replace function patents_data_function()
returns trigger as $$
declare
    table_name varchar;
    month_no int;
    DateAdd int;
    from_date date;
    tos_date date;
	t_year int;
	
begin
    select EXTRACT(month FROM new.patent_date) into month_no;
	select EXTRACT(year from new.patent_date) into t_year;
    table_name := format('patents_data_%s_%s_01', t_year, month_no);
    from_date:=t_year||'-'||month_no||'-01';
    DateAdd :=month_no + 1;
    tos_date:= t_year||'-'||DateAdd||'-01';
    perform 1 from pg_class where lower(relname) = lower(table_name) limit 1;
    
    if not found
    then
        execute format('create table %s (like patents_data including all)', table_name);
        execute format('alter table %s inherit patents_data, add check (patent_date >= ''%s'' and patent_date < ''%s'')',table_name, from_date, tos_date);
    end if;
    execute 'insert into ' || table_name || ' values ( ($1).* )' using new;
    return null;
end;
$$ 
language plpgsql;


create trigger insert_patents_data
before insert on patents_data for each row execute procedure patents_data_function();
