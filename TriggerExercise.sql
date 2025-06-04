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

/*2. Prevent Deletion of Products with Stock
Table: Products
Question:
Create a trigger that prevents deletion of a product from the Products table if the Stock is greater than 0. Raise a meaningful error message.*/

CREATE TABLE Products
(
    ProductID   INT IDENTITY PRIMARY KEY,
    ProductName NVARCHAR(60),
    Price       DECIMAL(10,2),
    Stock       INT
);
INSERT Products (ProductName, Price, Stock) VALUES
('Keyboard',   30.00, 15),
('Mouse',      15.00,  0),
('Webcam',     60.00,  5);


--create trigger
create trigger trPreventProducts
on Products
instead of delete
as
begin
	declare @ProductID int
	select @ProductID = ProductID from deleted
	if EXISTS(select 1 from deleted where Stock > 0)
	begin
		raiserror('Cannot delete product with stock remaining',16,1)
		return
	end
	delete from Products where ProductID = @ProductID
end;

delete from Products where ProductID = 1;

select * from Products;
