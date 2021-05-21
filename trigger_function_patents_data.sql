


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
    if month_no<10 then
        table_name := format('patents_data_%s_0%s', t_year, month_no);
    else
        table_name := format('patents_data_%s_%s', t_year, month_no);
    end if;
    
    from_date:=t_year||'-'||month_no||'-01';
    

        if month_no=12 then
            DateAdd:=1;
            t_year:=t_year+1;
        else
            DateAdd :=month_no + 1;
        end if;

    
    
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



create or replace function table_name_send() returns void as 
$$ 
declare
items record;
min_date record;
begin
RAISE NOTICE ' TABLE NAME              MINIMUM DATE     MAXIMUM DATE      ROW COUNT';
FOR items IN SELECT * FROM information_schema.tables where table_schema='public' order by table_name asc LOOP
        for min_date in execute format('select min(patent_date),max(patent_date),count(*) from '|| items.table_name) loop
            
            RAISE NOTICE ' % ,    % ,      %,      %', items.table_name ,min_date.min,min_date.max,min_date.count;
            end loop;
    END LOOP;

--perform print(unnest(table_ids));

end $$ language plpgsql;
