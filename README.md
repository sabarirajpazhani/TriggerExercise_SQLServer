# Questions

## 1. Log New User Registrations

**Tables: Users, Audit_Log**

**Write a trigger that fires after a new user is added to the Users table. Insert a record into Audit_Log with the UserID, action type as 'INSERT', and the current date-time.**

![image](https://github.com/user-attachments/assets/b3409059-0d1e-4a70-a9f6-e003b3afb64d)

## 2.Prevent Deletion of Products with Stock

**Table: Products**

**Create a trigger that prevents deletion of a product from the Products table if the Stock is greater than 0. Raise a meaningful error message.**

![image](https://github.com/user-attachments/assets/1478c083-58cb-4426-8320-c6c17a704981)
![image](https://github.com/user-attachments/assets/acfce976-bf2a-4751-ba96-e456fe5f14d6)

## 3. Track Employee Salary Changes

**Table(s): Employees, SalaryHistory**

**Write a trigger that captures changes to the Salary column in the Employees table. Store the EmpID, old salary, new salary, and the update time in SalaryHistory.**

![image](https://github.com/user-attachments/assets/1b3f78ee-5137-4608-ae20-3d94d804ee8f)

## 4. Auto Update 'LastModified' on Employee Update

**Table: Employees**

**Create a trigger that updates the LastModified column in the Employees table with the current date/time whenever a record is updated.**

![image](https://github.com/user-attachments/assets/8f520b3d-0072-4515-beb3-c5fc3401857d)

## 7. Prevent Price Reduction

**Table: Products**

**Create a trigger that checks if someone is trying to reduce the price of a product. If the new price is lower than the old one, raise an error and rollback the transaction.**

![image](https://github.com/user-attachments/assets/f3078eaf-47a6-414f-8693-34296a1f088c)

