use TriggerConcept;

/* 1. Log New User Registrations
Tables: Users, Audit_Log
Write a trigger that fires after a new user is added to the Users table. Insert a record into Audit_Log with the UserID, action type as 'INSERT', and the current date-time.*/

--Creating the Users Table
CREATE TABLE Users
(
    UserID      INT IDENTITY(1,1) PRIMARY KEY,
    UserName    NVARCHAR(50) NOT NULL,
    Email       NVARCHAR(100) UNIQUE,
    CreatedAt   DATETIME      DEFAULT (GETDATE())
);

--insert records to the Users Table
insert into Users values ('Alice','Alice@gmail.com','2023-10-23'),
('Bob','Bob@gmail.com','2024-10-09'),
('Charles','Charles@gmail.com','2024-11-10'),
('Daniel','Daniel@gmail.com','2025-01-10');

--creating the Audit_Log table
CREATE TABLE dbo.Audit_Log
(
    LogID       INT IDENTITY(1,1) PRIMARY KEY,
    UserID      INT,
    ActionType  NVARCHAR(20),
    ActionTime  DATETIME
);

--creating trigger
create trigger trNewUserLog
on Users
after insert
as
begin
	declare @UserID int
	select @UserID = UserID from inserted
	insert into Audit_Log
	values (@UserID, 'INSERT',Getdate());

	print 'New User with ID - '+cast(@UserID as varchar(20))+' is inserted Successfully'
end;

insert into Users values('Elizabeth','Elizabeth@gmail.com',getdate());

select * from Users;
select * from Audit_Log;