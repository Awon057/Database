drop table description;
drop table projects;
drop table employee;
drop table customer;

create table employee(
	e_code integer ,
	e_name varchar(20),
	designation varchar(20),
	sex varchar(20),
	salary integer,
	joining_date date,
   primary key(e_code)
);

create table customer(
	c_code integer,
	c_name varchar(20),
	occupation varchar(20),
	sex varchar(20),
	phone number(11),
   primary key(c_code)
);

create table projects(
	p_code varchar(20),
	p_name varchar(20),
	address varchar(20),
	budget integer,
	supervisor integer,
	customer integer,	
   primary key(p_code),
   foreign key(supervisor) references employee(e_code) on delete cascade,
   foreign key(customer) references customer(c_code) on delete cascade
);


create table description(
	s_no varchar(10),
	e_code integer ,
	c_code integer ,
	pre_address varchar(20),
	per_address varchar(20),
	date_of_birth date,
	email varchar(30),
   primary key(s_no),
   foreign key(e_code) references employee on delete cascade,
   foreign key(c_code) references customer on delete cascade
);

alter table description
	modify s_no integer;


CREATE OR REPLACE TRIGGER check_insertion BEFORE INSERT OR UPDATE ON employee
FOR EACH ROW
DECLARE
	c_min constant number(8,2) := 0.0;
	c_max constant number(8,2) := 50000.0;
BEGIN
   IF :new.salary > c_max OR :new.salary < c_min THEN
	RAISE_APPLICATION_ERROR(-20000,'New salary is too small or large');
   END IF;
END;
/

  
insert into employee values(0,'azdsfg','','male',0,'1-jun-2012');
insert into employee values(1012,'Rahim','engr','male',25000,'18-jan-2012');
insert into employee values(1013,'Karim','senior engr','male',35000,'1-jun-2007');
insert into employee values(1014,'Rahima','asst.engr','female',20000,'14-jan-2012');
insert into employee values(1015,'Rashed','asst.engr','male',20000,'11-may-2012');

insert into customer values(0,'asfd','teacher','male',01676892502);
insert into customer values(40001,'Md.asif','teacher','male',01676892502);
insert into customer values(40002,'Md.alamin','business','male',01676892555);
insert into customer values(40003,'Md.shaikat','business','male',01676892465);
insert into customer values(40004,'Emtious','business','male',01735665465);

insert into projects values('banani-1','suvastu banani','chairmanbari,banani',10000000,1013,40002);
insert into projects values('dhanmondi-4','suvastu planet','Dhanmondi-2',15000000,1012,40003);
insert into projects values('gazipur-1','gazipur homes','gazipur',8000000,1014,40001);
insert into projects values('Kh-1','Khulna Tower','Khulna',7000000,1015,40004);

insert into description(s_no,e_code,pre_address,per_address,date_of_birth,email) 
	values(10000,1012,'Jigatola','Khulna','20-jan-1986','rahim1012@yahoo.com');
insert into description(s_no,e_code,pre_address,per_address,date_of_birth,email) 
	values(10001,1013,'Jamalpur','shylet','1-jan-1983','karim@gmail.com');
insert into description(s_no,e_code,pre_address,per_address,date_of_birth,email) 
	values(10002,1014,'khulna','pirojpur','11-mar-1990','msrahima@hotmail.com');
insert into description(s_no,c_code,pre_address,per_address,date_of_birth,email) 
	values(10003,40001,'dhaka','dhaka','15-feb-1976','asifal@gmail.com');
insert into description(s_no,c_code,pre_address,per_address,date_of_birth,email) 
	values(10004,40002,'dhaka','sariatpur','20-jun-1992','alamin32@gmail.com');
insert into description(s_no,c_code,pre_address,per_address,date_of_birth,email) 
	values(10005,40003,'khulna','sathkhira','18-nov-1980','shaikatsaku@yahoo.com');
insert into description(s_no,c_code,pre_address,per_address,date_of_birth,email) 
	values(10006,40004,'Chittagong','Mongla','12-mar-1975','mdsazzad@hotmail.com');
insert into description(s_no,e_code,pre_address,per_address,date_of_birth,email) 
	values(10007,1015,'Dhaka','Mongla','18-apr-1980','rrashed@hotmail.com');



commit;

select * from employee
	where e_code!=0;
select * from customer
	where c_code!=0;
select * from projects;
select * from description;



select p.p_name,c.c_name,e.e_name from project p join;



select * from description
	WHERE e_code in(select e_code from employee where salary=35000);

select * from description
	WHERE e_code in(select supervisor from projects where p_code='dhanmondi-4');

select * from description
	WHERE c_code in(select customer from projects where p_code='banani-1');

select e.e_name,e.designation,d.pre_address,d.per_address,d.email
	from employee e join description d
	using(e_code);

select c.c_name,c.occupation,c.phone,d.pre_address,d.per_address,d.email
	from customer c natural join description d;

select max(salary) as Highest_salary from employee;

select count(p_code) as total_projects from projects;

select p_code,cc.p_name as project_name,cc.c_name as customer,cc.pre_address as customer_address,cc.email as customer_email,
	ee.e_name as employee,ee.pre_address as employee_address,ee.email as employee_email from 
 (select pc.p_code,pc.p_name,pc.c_name,d.pre_address,d.email from 
   (select p.p_code,p.p_name,c.c_name,p.customer from projects p join customer c on p.customer=c.c_code) pc 
	join description d on pc.customer=d.c_code) cc 
join 
 (select pe.p_code,pe.p_name,pe.e_name,d.pre_address,d.email from 
   (select p.p_code,p.p_name,e.e_name,p.supervisor from projects p join employee e on p.supervisor=e.e_code) pe 
	join description d on pe.supervisor=d.e_code) ee 
  using(p_code);



set serveroutput on
declare
	max_salary employee.salary%type;
	max_name   employee.e_name%type;
	PP_name    projects.p_name%type;
begin
	select max(salary) into max_salary from employee;

	select e_name into max_name from employee
	where salary=max_salary;
	select p_name into PP_name from projects
	where supervisor in(select e_code from employee where salary=max_salary);
	
	dbms_output.put_line('The maximum salary is : '|| max_salary  );
	dbms_output.put_line(' paid to :' ||max_name);
	dbms_output.put_line(' project supervised :'||PP_name);
end;
/
show error;

set serveroutput on
declare
	ssalary employee.salary%type;
begin
	select salary into ssalary from employee
	where e_code=1013;

	if ssalary=20000 then
	dbms_output.put_line('Assistant Engineer');

	elsif ssalary=25000 then
	dbms_output.put_line('Engineer');

	elsif ssalary=35000 then
	dbms_output.put_line('Senior Engineer');

	else
	dbms_output.put_line('Wrong input');
   end if;
end;
/	


SET SERVEROUTPUT ON
DECLARE
   counter    NUMBER(2):=1;
   c	      number(2);
   name       employee.e_name%TYPE;
   ssalary    employee.salary%TYPE;  
BEGIN
	select count(e_code) into c from employee;
	c:=c-1;
	dbms_output.put_line('Total valid employees: '|| c);
   WHILE counter <= c
   LOOP

      SELECT e_name,salary INTO name, ssalary
      FROM employee where counter=e_code-1011;

      DBMS_OUTPUT.PUT_LINE (counter||'.'||name || '-' || ssalary);
      DBMS_OUTPUT.PUT_LINE ('-----------');
	
	counter := counter + 1;

   END LOOP;

   EXCEPTION
      WHEN others THEN
         DBMS_OUTPUT.PUT_LINE (SQLERRM);
END;
/

SET SERVEROUTPUT ON
DECLARE
	CURSOR customer_cur IS
	select c_code,e_code,pre_address,email from description;	
	customer customer_cur%ROWTYPE;
BEGIN
	OPEN customer_cur;
    loop 
   FETCH customer_cur INTO customer;
   exit when customer_cur%notfound;

   DBMS_OUTPUT.PUT_LINE ('ECode : ' || customer.e_code||' CCode : ' || customer.c_code|| ' present_add:  ' ||customer.pre_address ||
	' Email: '||customer.email);
	end loop;

 CLOSE customer_cur;
END;
/


SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE nameph IS
	emp_id 	customer.c_code%type;
	name 	customer.c_name%type;
	ph 	customer.phone%type;
BEGIN
	emp_id := 40003;
	SELECT c_name,Phone INTO name,ph FROM customer
	WHERE c_code = emp_id;
	DBMS_OUTPUT.PUT_LINE('Name: '||name||' Phone: '||ph);
END;
/

BEGIN
	nameph;
END;
/


CREATE OR REPLACE FUNCTION Total_cost RETURN NUMBER IS
	total_budget projects.budget%type;
BEGIN
	SELECT sum(budget) INTO total_budget FROM projects;
	RETURN total_budget;
END;
/

SET SERVEROUTPUT ON
BEGIN
	dbms_output.put_line('Companys Total cost: ' || Total_cost);
END;
/


