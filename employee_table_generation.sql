-- employee table structure
create table emp_gen.employee_data(
    I_Emp_id INT GENERATED by default AS IDENTITY primary key,
    v_name   varchar,
    D_date_of_joining date,
    V_email varchar,
    I_manager_id  int references emp_gen.employee_data(I_Emp_id)

);

--function to create name,doj,email of employee
CREATE OR REPLACE FUNCTION emp_gen.field_format(I_Max_id int) RETURNS table(V_emp varchar,V_emai varchar,doj date,V_rand varchar) AS
$$
begin
--Generates random string for name
SELECT  array_to_string(ARRAY(SELECT chr((97 + round(random() * 25)) :: integer)
                        FROM generate_series(5,10)), '') into V_rand;
V_emp:=I_Max_id+1||'_'||V_rand;
V_emai:=V_rand||'@email.com';
--Generates random date from 2000-01-01 to yesterday
select  NOW() +random() * ( timestamp '2000-01-01' -(current_date - INTERVAL '1 day') )into doj ;
return next;
end;
$$ LANGUAGE PLPGSQL;


--Function to insert the employee data
CREATE OR REPLACE FUNCTION emp_gen.insert_Exec(I_Max_id int, V_emp_name varchar,D_doj Date,V_emai_id varchar,I_man_id integer) RETURNS void AS
$$
begin
EXECUTE 'insert into emp_gen.employee_data values ($1,$2,$3,$4,$5)' using I_Max_id+1, V_emp_name,D_doj,V_emai_id,I_man_id ;
end;
$$ LANGUAGE PLPGSQL;


--Main Function to generate employee data
CREATE OR REPLACE FUNCTION emp_gen.generate_emp_data(p_rows int) RETURNS void AS
$$
declare 
  I_Max_id int;
  V_rand_name varchar;
  V_emp_name varchar;
  V_emai_id varchar;
  D_doj date;
  I_Check_null integer;
  I_man_id integer;
  I_man_id_2 integer;
  I_start_loop integer;
  I_low integer;
  I_Existing_emp_id int[];
  R_insert_field record;
  R_fields record;
BEGIN
    I_start_loop:= 1;
    --Check the employee table is empty or not
    select count(*)  into I_Check_null from emp_gen.employee_data ;
    if I_Check_null=0 then
        --if table is empty then insert first employee who is top level employee
        INSERT INTO emp_gen.employee_data(v_name,D_date_of_joining,V_email) values ('1_RAMA','2001-05-08','rama@email.com');
        I_start_loop:=2;
    end if;
    -- start the loop from 1 (2 if employee table is empty as first employee was inserted earlier)
    for x in I_start_loop..p_rows loop
      -- Find max employee id
      select max(I_Emp_id)  into I_Max_id from emp_gen.employee_data;
      if I_Max_id-100 <=0 then 
            I_low:=1;
      else
            I_low:= I_Max_id-100;
      end if;
      -- Select random manager id from (max_emp_id +10 , max_emp_id-100) of new employee 
      select ceiling(random() * (abs((I_Max_id+10)-(abs(I_low)))) + (abs(I_low))+1)::int into I_man_id;
      -- call the function which generates name, email_id, doj
      select  V_emp as V_emp_name,V_emai  as V_emai_id,doj as D_doj from emp_gen.field_format(I_Max_id) into R_fields;
      begin
            --call the function to Insert the employee name,email_id, doj, Manager_id,employee_id
            select emp_gen.insert_Exec(I_Max_id,V_emp_name,D_doj,V_emai_id,I_man_id) into R_insert_field;
            --exception handling if generated manager id is not a existing employee id
            exception when foreign_key_violation then 
              --Make an array of all existing employee ids
              select array(SELECT (I_Emp_id) FROM emp_gen.employee_data ) into I_Existing_emp_id;
              -- Select random id as manager id from existing employee id 
              select I_Existing_emp_id[ceiling((random()*3)+1)::int] into I_man_id_2;
              I_Max_id:=I_man_id;
              -- call the function which generates name, email_id
              select V_emp as V_emp_name,V_emai  as V_emai_id from emp_gen.field_format(I_Max_id) into R_fields;
              --call the function to Insert the manager id as employee id , and insert existing employee as manager
              select emp_gen.insert_Exec(I_Max_id-1,V_emp_name,D_doj,V_emai_id,I_man_id_2) into R_insert_field;
              continue;
      end;
    end loop;
end;
$$ LANGUAGE PLPGSQL;
