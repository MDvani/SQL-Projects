/*==============
CREATE DATABSE
==================*/
create database EmployeesalesDB;
use EmployeesalesDB

/*===============
CREATE TABLES
=================*/
CREATE TABLE Departments_(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

CREATE TABLE Employees_(
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(50),
    DepartmentID INT,
    Salary DECIMAL(10,2),
    HireDate DATE,
    FOREIGN KEY (DepartmentID) REFERENCES Departments_(DepartmentID)
);

CREATE TABLE Sales_ (
    SaleID INT PRIMARY KEY,
    EmployeeID INT,
    Product VARCHAR(50),
    Amount DECIMAL(10,2),
    SaleDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees_(EmployeeID)
);

/*======================
INSERT VALUES INTO TABLES
=========================*/
INSERT INTO Departments_ VALUES
(1, 'HR'),
(2, 'Finance'),
(3, 'IT'),
(4, 'Sales');

INSERT INTO Employees_ VALUES
(101, 'Vani', 1, 45000, '2019-03-15'),
(102, 'Swaroop', 2, 55000, '2020-06-01'),
(103, 'Pavani', 3, NULL, '2021-01-20'),
(104, 'Durga', 4, 60000, '2018-07-30'),
(105, 'yasaswi', 4, 52000, '2022-05-12');

INSERT INTO Sales_ VALUES
(1, 104, 'Laptop', 1200, '2023-01-10'),
(2, 104, 'Mouse', 25, '2023-02-14'),
(3, 105, 'Keyboard', 45, '2023-03-18'),
(4, 105, 'Monitor', 300, '2023-04-22'),
(5, 102, 'Software', 2000, '2023-05-15'),
(6, 101, 'Training', 500, '2023-06-10'),
(7, 103, 'Server', 4000, '2023-07-25'),
(8, 104, 'Laptop', 1500, '2024-01-05'),
(9, 105, 'Monitor', 350, '2024-02-16');
/*===============JOINS===================*/
/*Show each employee’s name, department name, and salary.?*/
select 
e.Name,
d.departmentname,
e.salary
from Employees_ as e
left join Departments_ as d
on e.DepartmentID=d.DepartmentID;

/*Show each employee’s total sales amount with their department.?*/
select 
   e.employeeid,
   e.name,
   d.departmentname,
   coalesce(sum(s.Amount),0) as total_amount
from Employees_ as e
left join Departments_ as d
on e.DepartmentID=d.DepartmentID
left join Sales_ as s
on e.EmployeeID=s.EmployeeID
group by e.EmployeeID,e.name,DepartmentName
/*List employees who have not made any sales.?*/
SELECT 
    e.EmployeeID,
    e.Name,
    d.DepartmentName
FROM Employees_ e
LEFT JOIN Sales_ s 
    ON s.EmployeeID = e.EmployeeID
left JOIN Departments_ d
    ON e.DepartmentID = d.DepartmentID
WHERE s.SaleID IS NULL;
-- All are done sales,so output is empty.
INSERT INTO Employees_ (EmployeeID, Name, DepartmentID, Salary, HireDate)
VALUES (106, 'Frank', 2, 48000, '2023-09-01');
SELECT 
    e.EmployeeID,
    e.Name,
    d.DepartmentName
FROM Employees_ e
LEFT JOIN Sales_ s 
    ON s.EmployeeID = e.EmployeeID
left JOIN Departments_ d
    ON e.DepartmentID = d.DepartmentID
WHERE s.SaleID IS NULL;   --now it shows one employeeid who is not made any sales
/*==================SET OPERATORS======================*/

/*Find employees who made sales in 2023 but not in 2024.?*/
select distinct
       e.employeeid,
       e.name,
       year(s.saledate) as sale_year
from Employees_ as e
left join Sales_ as s
on e.EmployeeID=s.EmployeeID
where year(s.Saledate)=2023
except
select distinct
     e.employeeid,
     e.name,
     year(s.saledate) as sale_year
from Employees_ as e
left join Sales_ as s
     on e.EmployeeID=s.EmployeeID
where year(s.Saledate)=2024;

/*Find employees who made sales in both 2023 and 2024.*/
select distinct
       e.employeeid,
       e.name,
       year(s.saledate) as sale_year
from Employees_ as e
left join Sales_ as s
       on e.EmployeeID=s.EmployeeID
where  year(s.saledate)=2023
intersect
select distinct
     e.employeeid,
     e.name,
     year(s.saledate) as sale_year
from Employees_ as e
left join Sales_ as s
     on e.EmployeeID=s.EmployeeID
where year(s.saledate)=2024
and  year(s.saledate)is not null;
/*====================ROW-LEVEL-FUNCTIONS=======================*/
/*
Display employee names in uppercase with their joining year.*/
select 
     upper(name) as emp_name_in_uppercase,
     year(HireDate) as joining_year
from Employees_
/*Show employee names along with the length of their names.*/
select
    name as employee_name,
    len(name) as len_of_name
from Employees_
/*==================HANDLING NULLs===================*/
/*Show all employees, replacing NULL salaries with 30,000.?*/
select 
     e.employeeid,
     e.name,
     coalesce(e.salary,30000) as salary
from Employees_ as e
/*Show employees where salary is missing (NULL).*/
select 
* from Employees_
where Salary is null;
/*===============AGGREGATION=================*/
/*Find the average salary per department?*/
select 
   d.departmentname,
   coalesce(convert(int,round(avg(e.salary),0)),0) as avg_salary
from Employees_ as e
left join Departments_ as d
   on e.DepartmentID=d.DepartmentID
group by d.DepartmentName;
/*Find the highest and lowest salary across all employees?.*/
select
max(salary) as highest_salary,
min(salary) as lowest_salary
from Employees_
/*Show total sales per department.*/
select 
     d.departmentname,
     convert(int,round(sum(s.amount),0)) as total_sales
from Employees_ as e
left join Sales_ as s
     on e.EmployeeID=s.EmployeeID
left join Departments_ as d
    on e.DepartmentID=d.DepartmentID
group by DepartmentName

/*==============ANALYTICAL (WINDOW) FUNCTIONS=======================*/

/*Rank employees by their total sales amount (highest first)?*/
select
   e.employeeid,
   e.name,
   coalesce(s.amount,0) total_sales_amount,
   rank() over(order by s.amount desc) Rank_totalsalesamount
from Employees_ as e
left join sales_ as s
   on e.EmployeeID=s.EmployeeID

/*Assign a row number to employees based on their hire date.*/
select 
    e.employeeid,
    e.name,
    e.hiredate,
    ROW_NUMBER () over(order by e.hiredate) as rownumber
from Employees_ as e

/*Show a running total of sales for each employee.*/
SELECT 
    e.EmployeeID,
	e.name,
    s.Amount,
    SUM(coalesce(s.amount,0)) 
	OVER (PARTITION BY e.employeeid ORDER BY s.saleid 
	      ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM employees_ as e
   left join Sales_ as s
   on e.EmployeeID=s.EmployeeID
ORDER BY e.EmployeeID,s.SaleID
/*=======================SUBQUERIES==================*/

/*Find employees earning above the average salary.*/
select 
    EmployeeID,
    name,
	Salary
from Employees_
where salary>(
            select 
                isnull(avg(salary),0) 
	            from employees_
	       );
/*Find employees whose total sales are greater than Swaroop’s total sales.*/
select
       e.employeeid,
	   e.name,
	   sum(s.Amount) as total_sales
from Employees_ as e
left join Sales_ as s
      on s.EmployeeID=e.EmployeeID
	  Group by e.EmployeeID,e.Name
	  HAVING SUM(s.Amount) > (
    SELECT SUM(s2.Amount)
    FROM Employees_ e2
    JOIN Sales_ s2
        ON e2.EmployeeID = s2.EmployeeID
    WHERE e2.Name = 'swaroop'
);

	   
/*=======================VIEWS================*/
/*
Create a view showing each department with its total sales.
Stored Procedure*/

CREATE VIEW deptwithtotalsales 
AS
SELECT 
   d.Departmentname,
   sum(coalesce(s.amount,0)) as total_sales
from Departments_ as d
left join Employees_ as e
on e.DepartmentID=d.DepartmentID
left join Sales_ as s
on s.EmployeeID=e.EmployeeID
Group by d.DepartmentName;
select * from deptwithtotalsales
/*========================INDEX========================*/

/*Create an index on Sales(EmployeeID) to optimize queries.*/
CREATE NONCLUSTERED INDEX idx_Sales_EmployeeID
ON Sales_(EmployeeID);
--filtering by EmployeeID
SELECT * 
FROM Sales_
WHERE EmployeeID = 101;
-- joining Employees and Sales
SELECT e.Name, s.Amount
FROM Employees_ e
JOIN Sales_ s
    ON e.EmployeeID = s.EmployeeID
WHERE e.DepartmentID = 2;
/*==================================END======================*/
