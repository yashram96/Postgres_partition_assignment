

-- trigger function which gets triggerd on new data insert to parents_table
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
    select EXTRACT(month FROM new.patent_date) into month_no;     --Extract the month from new patent date
    select EXTRACT(year from new.patent_date) into t_year;        --Extract year from new patent date
    --To add prefix '0' to month if new month is single digit and forming new partition table name
    if month_no<10 then
        table_name := format('patents_data_%s_0%s', t_year, month_no); --example table name: patents_data_YYYY_MM
    else
        table_name := format('patents_data_%s_%s', t_year, month_no);
    end if;
    -- Forming a from_date string (YYYY-MM-DD) which is month starting
    from_date:=t_year||'-'||month_no||'-01';
    
    --Next month (if from_month is 12 then change increment year & month also or just add one to month )
        if month_no=12 then
            DateAdd:=1;
            t_year:=t_year+1;
        else
            DateAdd :=month_no + 1;
        end if;

    
    --Forming to_date
    tos_date:= t_year||'-'||DateAdd||'-01';
    -- Return if the partition table name is found or not
    perform 1 from pg_class where lower(relname) = lower(table_name) limit 1;
    
    if not found
    then
        -- If there is no partition table then create one and make it as child table to parent table
        execute format('create table %s (like patents_data including all)', table_name);
        execute format('alter table %s inherit patents_data, add check (patent_date >= ''%s'' and patent_date < ''%s'')',table_name, from_date, tos_date);
    end if;
        --Insert the data to partiton table
    execute 'insert into ' || table_name || ' values ( ($1).* )' using new;
    return null;
end;
$$ 
language plpgsql;

-- trigger  to be executed if the INSERT has happen to parent table (Patents_data)
create trigger insert_patents_data
before insert on patents_data for each row execute procedure patents_data_function();


-- Function to return the database status 
--1. table name
--2. minimum date of the table
--3. Maximum date of the table
--4. No of rows in a table 
create or replace function table_name_send1() returns table(item_table varchar,mindate date,maxdate date,total_count integer) as 
$$ 
declare
items record;
min_date record;
begin
-- for loop to extract min_date,Max_date,row_count from each table in database
FOR items IN SELECT * FROM information_schema.tables where table_schema='public' order by table_name asc LOOP
        for min_date in execute format('select min(patent_date),max(patent_date),count(*) from '|| items.table_name) loop
            item_table:=items.table_name ;
            mindate:=min_date.min;
            maxdate:=min_date.max;
            total_count:=min_date.count;
            return next ; -- return all the variables mentioned in function return table
            end loop;
    END LOOP;



end $$ language plpgsql;