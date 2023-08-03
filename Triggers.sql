--2 types - --after for triggers 
	--		insert of triggers

----------------------------------------------------DML----------------------------------------------------

SELECT table_name FROM information_schema.tables WHERE table_type='BASE TABLE'
use master
create table triggerTable(
[Emp_ID] [int] identity(1,1) primary key,
[Emp_Name] [varchar](100) NOT NULL,
[Emp_Salary] [decimal](10,2) not null,
[Emp_DOB] [datetime] not null,
[Emp_Experiance] [int] NOT NULL,
[Record_DateTime][datetime] not null
)

create trigger triggerafterInsert on triggerTable
AFTER INSERT
AS
declare @emp_dob varchar (20);
declare @Age int ;
declare @Emp_exp int;

select @emp_dob= i.Emp_DOB from inserted i;
select @Emp_exp= i.Emp_Experiance from inserted i;
-- Employee age must not above 25 years.
SET @Age = YEAR(GETDATE())- year(@emp_dob);
if @Age >25
begin 
print 'Not eligible : Age is greater than 25'
Rollback
End
---Employee should have more than 5 year experiance 
else if @Emp_exp <5
begin 
print 'not Eligible : Experiance is less than 5'
Rollback 
end 
ELSE
	BEGIN
	Print 'Employee details inserted successfully';
	END


INSERT INTO triggerTable values ('Prajwal',5000,'1990-01-03',4,GETDATE()) 
-- THis will throw error -----Not eligible : Age is greater than 25

INSERT INTO triggerTable values('Prajwal',5000,'1999-01-03',4,GETDATE()) 
--not Eligible : Experiance is less than 5

INSERT INTO triggerTable values('Prajwal',5000,'1999-01-03',6,GETDATE())
-- now data will insert

select * from triggerTable

-- update trigger 
-- while updating record must contain old and new value
-- so create new table EmployeeHistory

CREATE TABLE EmployeeHistory(
[Emp_ID] [int] not null,
[Field_Name] [varchar](100) not null,
[old_value] [varchar](100) not null,
[new_value] [varchar](100) not null,
[Rocord_DateTime] [datetime] not null
)

create TRIGGER triggerAfterUpdate on triggerTable
AFTER UPDATE 
AS
declare @emp_id INT;
declare @emp_name varchar(100);
declare @old_emp_name varchar(100);
declare	@emp_sal decimal(10,2);
declare @old_emp_sal decimal(10,2);

select @emp_id= i.Emp_ID from inserted i ;
select @emp_name= i.Emp_Name from inserted i ;
select @old_emp_name = i.Emp_name from deleted i;
select @emp_sal = i.Emp_Salary from inserted i;
select @old_emp_sal = i.Emp_Salary from deleted i;

if update (Emp_Name)
BEGIN 
INSERT INTO EmployeeHistory values (@emp_id,'Emp_name',@old_emp_name,@emp_name,GETDATE())
end
if update (Emp_Salary)
begin 
insert into EmployeeHistory values (@emp_id,'Emp_Sal',@old_emp_sal,@emp_sal,GETDATE())
end

select * from triggerTable;

select * from EmployeeHistory;

update triggerTable set Emp_Name = 'Prajkta' where Emp_ID=3




----------------------------------------------------DDL----------------------------------------------------
CREATE DATABASE DDLTRIGGER
USE DDLTRIGGER
DROP table test


create table DeleteTable
(ID int)

CREATE trigger ddlTrigger 
on DATABASE
FOR CREATE_TABLE
AS
BEGIN
PRINT 'YOU CANNOT CREATE A TABLE IN THIS DB '
ROLLBACK TRANSACTION
END



CREATE trigger ddlTrigger1
on DATABASE
FOR CREATE_TABLE,ALTER_TABLE,UPDATE_TABLE
AS
BEGIN
PRINT 'YOU CANNOT CREATE A TABLE IN THIS DB '
ROLLBACK TRANSACTION
END



 -----------------------------audit-------------------------------------------------
 CREATE TABLE TableAudit
 (
 DatabaseName nvarchar(250),
 TableName nvarchar(250),
 EventType nvarchar(250),
 LoginName nvarchar(250),
 SQLCommand nvarchar(2500),
 AuditDateTime datetime
 )

 create trigger TRIGGERAUDIT
 on all server 
 for DDL_TABLE_EVENTS
 as 
 begin 
 declare @EventData xml
 SELECT @EventData = EVENTDATA()
 insert into TableAudit 
 (DatabaseName,TableName,EventType,LoginName,SQLCommand,AuditDateTime)
 values(
 @EventData.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(250)'),
 @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(250)'),
 @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(250)'),
 @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(250)'),
 @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(250)'),
 GETDATE()
 )
 END

 select * from TableAudit


 -------------------------------------CURSOR----------------------------------------
 use OrderManagementSystem
 select * from Customers


 DECLARE @Name nvarchar(40)
 
 declare mycursor cursor for 
 select concat(FirstName,' ',LastName) as FUllName from Customers where FirstName is not null

 open mycursor
 fetch next from mycursor into @Name

 while @@FETCH_STATUS =0
 begin
	select @Name = @name 
	fetch next from mucursor into @name