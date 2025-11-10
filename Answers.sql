-- ====================
-- Part 1
-- ====================

create table department(
	did int primary key,
    dname varchar(50) unique not null,
    budget float check (budget > 0),
    managerId int null
);

create table employee(
	eid int primary key,
    ename varchar(100) not null,
    age int,
    salary float default 30000,
    did int,
    constraint department_id_fk foreign key (did) references department(did)
);

alter table department add
constraint manager_id_fk foreign key (managerId) references employee(eid);

create table project(
	pid int primary key,
    pname varchar(100) unique,
    deadline date
);

create table works_on(
	eid int,
    pid int,
    hours_worked int check (hours_worked>0),
    constraint pk_works_on primary key (eid, pid),
    constraint employee_id_fk foreign key (eid) references employee(eid),
    constraint project_id_fk foreign key (pid) references project(pid)
);

create table salary_audit(
	logId int primary key identity(1,1),
    eid int,
    old_salary float,
    new_salary float,
    change_data datetime
);


-- ====================
-- Part 2
-- ====================

-- 1.
insert into department(did,dname,budget) values
    (1,'Sales',500000),
    (2,'Engineering',1000000);

insert into employee(eid, ename, age, salary, did) values
    (1,'Alice',40,90000,1),
    (2,'Bob',45,110000,2),
    (3,'Charlie',28,70000,2);

update department set managerId=1 where did=1;
update department set managerId=2 where did=2;

insert into project(pid, pname, deadline) values
    (1,'Project Alpha','2025-12-31'),
    (2,'Project Beta', '2026-06-30');

insert into works_on(eid, pid, hours_worked) values
    (3,1,40),
    (2,1,10),
    (1,2,20);

-- 2.
update employee set salary=salary*1.10 where eid=3;

-- 3.
insert into project(pid, pname, deadline) values
    (3,'Project Gamma','2025-12-10');

delete from project where pid=3;


-- ====================
-- Part 3
-- ====================

-- 1.
select ename, age from employee
where salary>80000;

-- 2.
select pname from project
where pname like '%Alpha%'
order by pname desc;

-- 3.
select ename, salary from employee
where salary between 60000 and 100000;

-- 4.
select eid, ename from employee
where did is null;

-- 5.
select eid, AVG(salary) as emp_salary, SUM(budget) as dep_budget, MAX(age) as emp_age  from employee, department
group by eid;

-- 6.
select did from employee group by did having COUNT(eid) > 5;

-- 7.
select e.ename, d.dname from employee e
join department d on e.did = d.did;

-- 8.
select e.ename, p.pname, wo.hours_worked from employee e
join works_on wo on e.eid = wo.eid
join project p on p.pid = wo.pid;

-- 9.
select e.ename, p.pname from employee e
left join works_on wo on e.eid = wo.eid
left join project p on wo.pid = p.pid;

-- 10.
select e.ename, p.pname from employee e
join works_on wo on e.eid = wo.eid
right join project p on wo.pid = p.pid; 

-- 11.
select ename, salary from employee
where did in (select did from department where dname='Engineering');

-- 12.
select ename from employee 
where salary > ANY(
    select e.salary from employee e
    join department d on e.eid=d.managerId
);


-- ====================
-- Part 4
-- ====================

-- 1.
create view v_engineering_employees(eid, ename, salary) as
select e.eid, e.ename, e.salary from employee e
join department d on e.eid=d.did
where d.dname='Engineering';

-- 2.
create view v_Project_Summary as
select p.pid, p.pname, SUM(wo.hours_worked) as total_hours from project p
join works_on wo on wo.pid=p.pid
group by p.pid, p.pname;

-- 3.
select * from v_engineering_employees2
where salary<75000

-- 4.
drop view v_engineering_employees;


-- ====================
-- Part 5
-- ====================

create function getTotalHours(@eid int) returns int as
begin
    declare @tolH int
    select @tolH=sum(hours_worked) from works_on
    where eid=@eid
    return @tolH
end

declare @funcR int
exec @funcR=getTotalHours 2;
print @funcR


create procedure assignProject(@empId int, @projId int) as
begin
	insert into works_on(eid, pid, hours_worked)
	values (@empId,@projId,10);
end

declare @procR int
exec @procR=assignProject 4,1;
print @procR
select * from works_on;

create procedure getDeptStats(@dname varchar, @did int output, @budget float output, @tol int output) as
begin
	select @did=d.did, @budget=d.budget, @tol=COUNT(e.eid) from department d
	join employee e on e.did=d.did
	group by d.did, d.budget
end;

declare @procR11 int, @procR12 float, @procR13 int
exec getDeptStats @dname='Engineering', @did=@procR11 output, @budget=@procR12 output, @tol=@procR13 output;
print @procR11
print @procR12
print @procR13

create trigger  trg_AuditSalary2
on Employee
after update as
begin
	if UPDATE(salary)
	begin
		declare @eid int
		declare @new_sal float
		declare @old_sal float
		declare @cDate date

		select @eid=i.eid, @old_sal=i.salary, @cDate=GETDATE()  from inserted i
		insert into salary_audit(eid, old_salary, new_salary, change_data)
		values(@eid, @old_sal, @new_sal, @cDate)
	end
end;

UPDATE Employee
SET salary = 45000.00
WHERE eid = 3;

select * from Salary_Audit

create trigger  trg_SafeDeleteDept
on department
instead of delete, update as
begin
	set nocount on;

	declare @did int, @eid int;
	select @did=did from deleted;

	update employee set did=null where @did=did;
	delete from department where did=@did;

	print 'Department removed and employees unassigned.';
end;



delete from department where did = 1

select * from department
select * from employee

