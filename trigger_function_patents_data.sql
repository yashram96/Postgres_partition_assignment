

-- trigger function which gets triggerd on new data insert to parents_table
create or replace function patents_data_function()
returns trigger as $$
declare
    V_table_name varchar;
    I_month_no int;
    I_DateAdd int;
    D_from_date date;
    D_tos_date date;
    I_t_year int;
    
begin
    select EXTRACT(month FROM new.patent_date) into I_month_no;     --Extract the month from new patent date
    select EXTRACT(year from new.patent_date) into I_t_year;        --Extract year from new patent date
    --To add prefix '0' to month if new month is single digit and forming new partition table name
    if I_month_no<10 then
        V_table_name := format('patents_data_%s_0%s', I_t_year, I_month_no); --example table name: patents_data_YYYY_MM
    else
        V_table_name := format('patents_data_%s_%s', I_t_year, I_month_no);
    end if;
    -- Forming a from_date string (YYYY-MM-DD) which is month starting
    D_from_date:=I_t_year||'-'||I_month_no||'-01';
    
    --Next month (if from_month is 12 then change increment year & month also or just add one to month )
    if I_month_no=12 then
        I_DateAdd:=1;
        I_t_year:=I_t_year+1;
    else
        I_DateAdd :=I_month_no + 1;
    end if;

    
    --Forming to_date
    D_tos_date:= I_t_year||'-'||I_DateAdd||'-01';
    -- Return if the partition table name is found or not
    perform 1 from pg_class where lower(relname) = lower(V_table_name) limit 1;
    
    if not found
    then
        -- If there is no partition table then create one and make it as child table to parent table
        execute format('create table %s (like patents_data including all)', V_table_name);
        execute format('alter table %s inherit patents_data, add check (patent_date >= ''%s'' and patent_date < ''%s'')',V_table_name, D_from_date, D_tos_date);
    end if;
        --Insert the data to partiton table
    execute 'insert into ' || V_table_name || ' values ( ($1).* )' using new;
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
create or replace function table_name_send1() returns table(V_item_table varchar,D_mindate date,D_maxdate date,I_total_count integer) as 
$$ 
declare
R_items record;
R_min_date record;
begin
-- for loop to extract min_date,Max_date,row_count from each table in database
FOR R_items IN SELECT * FROM information_schema.tables where table_schema='public' order by table_name asc LOOP
        for R_min_date in execute format('select min(patent_date),max(patent_date),count(*) from '|| R_items.table_name) loop
            V_item_table:=R_items.table_name ;
            D_mindate:=R_min_date.min;
            D_maxdate:=R_min_date.max;
            I_total_count:=R_min_date.count;
            return next ; -- return all the variables mentioned in function return table
        end loop;
END LOOP;
end $$ language plpgsql;





# creating audit table
create table audit_data(
    S_id_no  serial,
    V_patent_number varchar,
    D_patent_date date,
    V_patent_title varchar,
    V_username varchar not null,
    V_field_changed varchar,
    T_modified_at timestamp not null,
    C_Operation char(10) not null,
    primary key(S_id_no)
);

select * from audit_data;


   
#trigger which activated during insert/update/delete functions on patents_data table
create trigger db_audit_table after insert or update or delete on patents_data
for each row execute procedure audit_function();


# Trigger function which audits the table
create or replace function audit_function() returns trigger as  
$$
begin
    if (TG_OP = 'DELETE') then # For delete operation on table
        insert into audit_data( V_patent_number,
                                D_patent_date,
                                V_patent_title,
                                V_username,
                                V_field_changed,
                                T_modified_at,
                                C_Operation) SELECT OLD.*, user , 'All deleted' , now(), 'DELETE';
    elsif (TG_OP = 'UPDATE') then #For UPDATE operation on table
        if new.patent_date!=old.patent_date then
            insert into audit_data( V_patent_number,
                                    D_patent_date,
                                    V_patent_title,
                                    V_username,
                                    V_field_changed,
                                    T_modified_at,
                                    C_Operation) SELECT OLD.*, user , 'patent_date' , now() ,'UPDATE';
        elsif new.patent_number!=old.patent_number then
            insert into audit_data( V_patent_number,
                                    D_patent_date,
                                    V_patent_title,
                                    V_username,
                                    V_field_changed,
                                    T_modified_at,
                                    C_Operation) SELECT OLD.*, user , 'patent_number', now() ,'UPDATE';
        elsif new.patent_title!=old.patent_title then
            insert into audit_data( V_patent_number,
                                    D_patent_date,
                                    V_patent_title,
                                    V_username,
                                    V_field_changed,
                                    T_modified_at,
                                    C_Operation) SELECT OLD.*, user , 'patent_title' , now(),'UPDATE';
        end if;
    elsif (TG_OP = 'INSERT') then #For INSERT operation on table
        if new.patent_date!=old.patent_date then
            insert into audit_data( V_patent_number,
                                    D_patent_date,
                                    V_patent_title,
                                    V_username,
                                    V_field_changed,
                                    T_modified_at,
                                    C_Operation)  SELECT OLD.*, user , 'patent_date' , now() ,'INSERT';
        elsif new.patent_number!=old.patent_number then
            insert into audit_data( V_patent_number,
                                    D_patent_date,
                                    V_patent_title,
                                    V_username,
                                    V_field_changed,
                                    T_modified_at,
                                    C_Operation) SELECT OLD.*, user , 'patent_number' , now() ,'INSERT';
        elsif new.patent_title!=old.patent_title then
            insert into audit_data( V_patent_number,
                                    D_patent_date,
                                    V_patent_title,
                                    V_username,
                                    V_field_changed,
                                    T_modified_at,
                                    C_Operation) SELECT OLD.*, user , 'patent_title' , now(),'INSERT';
        end if;
    end if;

    return null;

end;
$$ language plpgsql;
