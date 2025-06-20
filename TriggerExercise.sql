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


/*3. Track Employee Salary Changes
Table(s): Employees, SalaryHistory
Question:
Write a trigger that captures changes to the Salary column in the Employees table. Store the EmpID, old salary, new salary, and the update time in SalaryHistory.*/

--creating Employee Table
CREATE TABLE Employees
(
    EmpID        INT IDENTITY(1,1) PRIMARY KEY,
    EmpName      NVARCHAR(60),
    Salary       DECIMAL(12,2),
    LastModified DATETIME DEFAULT (GETDATE())
);
CREATE TABLE SalaryHistory
(
    HistID     INT IDENTITY(101,1) PRIMARY KEY,
    EmpID      INT,
    OldSalary  DECIMAL(12,2),
    NewSalary  DECIMAL(12,2),
    ChangedAt  DATETIME
);
INSERT Employees (EmpName, Salary) VALUES
('Sam', 50000),
('Rita',65000);

--creating trigger
create trigger trEmployeeSalaryLog
on Employees
after update
as
begin
	declare @OldSalary int, @NewSalary int,@EmpID int
	select @EmpID = EmpID , @NewSalary = Salary from inserted
	select @OldSalary = Salary from deleted where EmpID =@EmpID

	insert into SalaryHistory
	values (@EmpID, @OldSalary,@NewSalary,GETDATE())

	print 'Salary has been Successfully Updated'
end

update Employees 
set Salary = 70000
where EmpID = 2;


select * from Employees;
select * from SalaryHistory;

/*4. Auto Update 'LastModified' on Employee Update
Table: Employees
Question:
Create a trigger that updates the LastModified column in the Employees table with the current date/time whenever a record is updated.*/
--Create Employees2 table
create table Employee2(
	EmpID int IDENTITY(1,1) primary key,
	EmpName varchar(40),
	Salary int,
	LastModified datetime
);
insert into Employee2 values
('Alice', 25000, '2024-01-11'),
('Bob',30000, '2024-10-23');

--create trigger
create trigger trEmployeeUpdateLog
on Employee2
after update
as 
begin
	declare @EmpID int
	select @EmpID = EmpID from inserted

	declare @LastUpdate datetime
	set @LastUpdate = GETDATE()
	update Employee2
	set LastModified = @LastUpdate
	where EmpID = @EmpID
end

update Employee2
set Salary = 45000
where EmpID = 1;

select * from Employee2;


/*6. Reduce Stock When Order Placed
Table(s): OrderDetails, Inventory
Question:
Write a trigger that reduces the Stock in the Inventory table when a new row is inserted into OrderDetails. Ensure that stock doesn’t go below zero — raise an error if there’s not enough stock.*/

create trigger trReduceStock
on OrderDetails
after insert
as
begin
	DECLARE @OrderID INT;
    DECLARE @TotalPrice DECIMAL(10,2);
    DECLARE @Quantity INT;
    DECLARE @ProductID INT;
	DECLARE @CurrentStock int;

    SELECT 
        @OrderID = OrderID, 
        @TotalPrice = Quantity * Price,
        @Quantity = Quantity,
        @ProductID = ProductID
    FROM inserted;

	SELECT @CurrentStock = Stock from Products where ProductID = @ProductID
	
	if(@Quantity <=0 or @Quantity > @CurrentStock)
	begin
		raiserror('Not enough stock to place the order.', 16, 1);
		return
	end

	update Orders
	set TotalAmount =TotalAmount+ @TotalPrice
	where OrderID = @OrderID

	update Products
	set Stock = Stock - @Quantity
	where ProductID = @ProductID

end

drop trigger trReduceStock


insert into OrderDetails values
(2,3, 5,60);


select * from Orders;
select * from OrderDetails;
select * from Products;


/*7. Prevent Price Reduction
Table: Products
Question:
Create a trigger that checks if someone is trying to reduce the price of a product. If the new price is lower than the old one, raise an error and rollback the transaction.*/

select * from Products;

create trigger trPreventPrice
on Products
after update
as
begin
	if exists(
		select 1 from inserted i
		join deleted d 
		on i.ProductID = d.ProductID
		where i.Price < d.Price	
	)
	begin
		raiserror('Price reduction is not allowed ',16,1)
		rollback
	end
end

update Products
set Price = 40
where ProductID = 1;


/*8. Log Deleted Customer Info
Table(s): Customers, DeletedCustomers
Question:
Write a trigger that copies deleted customer information to the DeletedCustomers table along with a timestamp when a record is deleted from the Customers table.*/

--creting the customers table
create table Customers (
	CustomerID int identity(1,1) primary key,
	CustomerName varchar(60),
	Email varchar(90),
	Phone varchar(20)
);

insert into Customers values
('Arun','Arun@gmail.com','9876543234'),
('Balaji', 'Balaji@gmail.com','98762546378');

create table DeletedCustomers(
	CustomerID int,
	DateAndTime datetime
);
--create trigger

create trigger trCustomerLog
on Customers
after delete 
as
begin
	declare @CustomerID int
	select @CustomerID = CustomerID from deleted

	
	delete from Customers
	where CustomerID = @CustomerID

	insert into DeletedCustomers values 
	(@CustomerID, GETDATE())
end;

delete from Customers
where CustomerID = 2;

select * from Customers;
select * from DeletedCustomers;

/*9. One Order Per Day per Customer
Table: Orders
Question:
Write a trigger that prevents a customer from inserting more than one order in a single day. Raise an error if they attempt to do so.*/
create trigger trOrderPerDay
on Orders
after insert
as
begin
	if exists (
		select 1 from inserted i
		join Orders o 
		on o.CustomerID = i.CustomerID and cast(o.OrderDate as date) = cast(i.OrderDate as date)
	)
	begin
		raiserror ('Only one order per day is allowed per customer.', 16, 1);
		return
	end

	insert into Orders (CustomerID, OrderDate, TotalAmount)
	select CustomerID, OrderDate, TotalAmount from inserted;
end

drop trigger trOrderPerDay

insert into Orders values
(2, Getdate(), 3500);

select * from Orders;


/*10. Log Contact Changes for Customers
Table: Customers
Question:
Create a trigger that logs changes only when either the Email or Phone of a customer is updated. You may optionally create a CustomerChanges table to store old and new values.*/
create table CustomerChanges(
	CustomerID int,
	OldEmail varchar(80),
	NewEmail varchar(80),
	OldPhone varchar(30),
	NewPhone varchar(30)
);
select * from Customers;

create trigger trContactLog
on Customers
after update
as
begin
	declare @CustomerID int
	declare @OldEmail varchar(80), @NewEmail varchar(80)
	declare @OldPhone varchar(30), @NewPhone varchar(30)
	select 
		@OldEmail = Email, 
		@OldPhone = Phone
	from deleted

	select 
		@CustomerID = CustomerID,
		@NewEmail = Email,
		@NewPhone = Phone
	from inserted

	insert into CustomerChanges values
	(@CustomerID,@OldEmail,@NewEmail,@OldPhone,@NewPhone)

	if(update(Email))
	begin
		Update Customers
		set Email = @NewEmail
		where CustomerID = @CustomerID
	end

	if(update(Phone))
	begin
		update Customers
		set Phone = @NewPhone
		where CustomerID = @CustomerID
	end
end

drop trigger trContactLog

update Customers
set Email = 'Balaji007@gmail.com' ,
	Phone = '8987543276'
where CustomerID = 3;
		
select * from Customers;
select * from CustomerChanges;

