

----------------------------------------------
-- Employee data table structure
create table employee_data(
    I_Emp_id INT GENERATED ALWAYS AS IDENTITY primary key,
    v_name   varchar,
    D_date_of_joining date,
    V_email varchar,
    V_position varchar ,
    I_manager_id  int references employee_data(I_Emp_id)

);



-- Table data of employee
insert into employee_data(v_name,D_date_of_joining,V_email,V_position,I_manager_id) values
                            ('Rama','2014-02-20','ram@gmail.com','SE1',null),
                            ('vara','2014-02-20','vara@gmail.com','SE1',21),
                            ('prasad','2014-02-20','prasad@gmail.com','SE1',8),
                            ('swami','2014-02-20','swami@gmail.com','SE1',18),
                            ('manoj','2014-02-20','manoj@gmail.com','SE1',17),
                            ('aneesh','2014-02-20','aneesh@gmail.com','SE1',15),
                            ('yeswanth','2014-02-20','yeswanth@gmail.com','SE1',3),
                            ('mohan','2014-02-20','mohan@gmail.com','SE1',9),
                            ('ramya','2014-02-20','ramya@gmail.com','SE1',18),
                            ('priya','2014-02-20','priya@gmail.com','SE1',12),
                            ('lakshmi','2014-02-20','lakshmi@gmail.com','SE1',21),
                            ('surya','2014-02-20','surya@gmail.com','SE1',13),
                            ('karthik','2014-02-20','karthik@gmail.com','SE1',10),
                            ('pavan','2014-02-20','pavan@gmail.com','SE1',6),
                            ('jaya','2014-02-20','jaya@gmail.com','SE1',4),
                            ('nag','2014-02-20','nag@gmail.com','SE1',2),
                            ('kumar','2014-02-20','kumar@gmail.com','SE1',1),
                            ('sita','2014-02-20','sita@gmail.com','SE1',24),
                            ('raj','2014-02-20','raj@gmail.com','SE1',20),
                            ('sindhu','2014-02-20','sindhu@gmail.com','SE1',12),
                            ('akbar','2014-02-20','akbar@gmail.com','SE1',19),
                            ('Manu','2014-02-20','Manu@gmail.com','SE1',14),
                            ('kareem','2014-02-20','kareem@gmail.com','SE1',17),
                            ('Martin','2014-02-20','Martin@gmail.com','SE1',17)
;



-- Table to visualise the hierarchy level
 with recursive emp_data_par as
(   
    --finds the employee who has no managers
    select I_Emp_id,v_name ,'{} '::int[] as higher_auth, 0 as level
    from employee_data
    where i_manager_id is NULL

    union all 

    --recurse the iteration till end who was not managing
    select c.I_Emp_id, c.v_name, higher_auth || c.i_manager_id, level+1
            from emp_data_par p
            join employee_data c
            on c.i_manager_id = p.I_Emp_id
            where not c.I_Emp_id = any(higher_auth)
)select * from emp_data_par;



--function to create json format of hierarchy
CREATE OR REPLACE FUNCTION json_tree_emp(I_root_id int) RETURNS JSONB AS
$$
declare 
  V_name_s varchar;
  V_desig varchar;
BEGIN
  SELECT v_name ,V_position into V_name_s, V_desig FROM employee_data WHERE I_Emp_id = I_root_id;
  --json object structure 
  RETURN json_build_object('I_Emp_id',I_root_id,'v_name',V_name_s,'Position',V_desig,'c_manage',
                                                                                    array(
                                                                                    SELECT json_tree_emp(I_Emp_id)
                                                                                    FROM employee_data 
                                                                                    WHERE i_manager_id = I_root_id
                                                                                    ) );
END;
$$ LANGUAGE PLPGSQL;

-- call the function with argument of employee id
SELECT jsonb_pretty(json_tree_emp(1));
