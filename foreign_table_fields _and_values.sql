create schema foreign_field;

create table foreign_field.employee_table(
  S_id  serial not null primary key,
  V_field_name   varchar
);


CREATE TABLE foreign_field.employee_field_values(
  S_id serial primary key,
  I_field_id int REFERENCES foreign_field.employee_table(S_id),
  V_field_values varchar
  
);
insert into foreign_field.employee_table values (1, 'em_id'),
(2,'name'),
(3, 'DOJ'),
(4,' position'),
(5, 'email_id'),
(6, 'salary'),
(7,' Address'),
(8, 'Manager_Id'),
(9, 'Branch'),
(10, 'blood_group');

Insert into foreign_field.employee_field_values values
(1,1,1001),
(2,2,'YESWANTH'),
(3,3,'2021-01-01'),
(4,4,'SE1'),
(5,5,'KASI@GMAIL.COM'),
(6,6,'400000'),
(7,7,'9-4 ,BHADRACHALAM'),
(8,8,'102'),
(9,9,'CHENNAI'),
(10,10,'B+')