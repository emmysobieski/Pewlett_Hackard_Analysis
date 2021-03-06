-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);

CREATE TABLE employees (
	emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

CREATE TABLE "dept_emp" (
    "emp_no" INT   NOT NULL,
    "dept_no" VARCHAR(4)   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    CONSTRAINT "pk_Dept_Emp" PRIMARY KEY (
        "emp_no","dept_no"
     )
);

CREATE TABLE "titles" (
    "emp_no" INT   NOT NULL,
    "title" VARCHAR  NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
    CONSTRAINT "pk_Titles" PRIMARY KEY (
        "emp_no","title","from_date"
     )
);

-- Confirm number of rows in table called departments
SELECT * FROM departments;

--Exploring employees born between Jan 1, 1952 and Dec 31, 1955
SELECT COUNT(*)
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

-- Narrowing retirement eligibility to age and length of service
-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(*)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Check the table
SELECT * FROM retirement_info;

-- Joining departments and dept_manager tables
SELECT departments.dept_name,
     dept_manager.emp_no,
     dept_manager.from_date,
     dept_manager.to_date
FROM departments
INNER JOIN dept_manager
ON departments.dept_no = dept_manager.dept_no;

-- Joining retirement_info and dept_emp tables to
-- make sure those eligible for retiring are currently employed
SELECT retirement_info.emp_no,
	retirement_info.first_name,
retirement_info.last_name,
	dept_emp.to_date
FROM retirement_info
LEFT JOIN dept_emp
ON retirement_info.emp_no = dept_emp.emp_no;

-- USING ALIAS CODE Joining retirement_info and dept_emp tables to
-- make sure those eligible for retiring are currently employed
SELECT ri.emp_no,
	ri.first_name,
ri.last_name,
	de.to_date
FROM retirement_info AS ri
LEFT JOIN dept_emp AS de
ON ri.emp_no = de.emp_no;

-- Joining departments and dept_manager tables using aliases
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments AS d
INNER JOIN dept_manager AS dm
ON d.dept_no = dm.dept_no;

-- Retirement-eligible employees who are still employed
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
de.to_date
INTO current_emp
FROM retirement_info AS ri
LEFT JOIN dept_emp AS de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO retirement_by_dept
FROM current_emp AS ce
LEFT JOIN dept_emp AS de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- Exploring Salaries table to see how to merge it with employee table
SELECT * FROM salaries
ORDER BY to_date DESC;

-- Create new table emp_info with employee number, full name, gender, age, tenure
SELECT emp_no,
	first_name,
last_name,
	gender
INTO emp_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

DROP TABLE emp_info;

-- Join emp_info with salaries data
SELECT e.emp_no,
	e.first_name,
e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees AS e
INNER JOIN salaries AS s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp AS de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
     AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	 AND (de.to_date = '9999-01-01');
	 
-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
		
-- Department Retirees list into dept_info
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info
FROM current_emp AS ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);

-- Employees retiring from Sales Department
SELECT di.emp_no,
	di.first_name,
	di.last_name,
	di.dept_name
INTO retirement_sales
FROM dept_info AS di
WHERE (di.dept_name = 'Sales');

-- Employees retiring from Sales and Development Departments
SELECT di.emp_no,
	di.first_name,
	di.last_name,
	di.dept_name
INTO retirement_sales_devt
FROM dept_info AS di
WHERE di.dept_name IN ('Development', 'Sales');



------------ CHALLENGE START---------------
---Determine the titles of employees who are expected to retire, 
-- using the previously-created table retirement_info
SELECT ri.emp_no,
ri.first_name,
ri.last_name,
ti.title,
ti.to_date,
ti.from_date,
s.salary
INTO retiring_emp_by_title
FROM retirement_info AS ri
INNER JOIN salaries AS s
ON (ri.emp_no = s.emp_no)
INNER JOIN titles AS ti
ON (ri.emp_no = ti.emp_no);

-- check to see data from table.  There are duplicates
SELECT * FROM retiring_emp_by_title;

-- Partition the data to show only most recent title per employee,
-- which will remove duplicates to create final table
SELECT tmp.emp_no,
tmp.first_name,
tmp.last_name,
tmp.title,
tmp.from_date,
tmp.salary
INTO partitioned_retiring_emp_by_title
FROM 
 (SELECT emp_no,
first_name,
last_name,
  title,
from_date,
salary, 
  ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM retiring_emp_by_title
 ) tmp WHERE rn = 1
ORDER BY emp_no;

--Reordered the table of retiring employees by title
SELECT * FROM partitioned_retiring_emp_by_title
ORDER BY title;

------Show number of employees within each title who are retiring
SELECT COUNT(*) AS employees_per_title_retiring,
title
FROM partitioned_retiring_emp_by_title
GROUP BY title;

-- Create new table showing number of employees within each title who are retiring
SELECT COUNT(pret.title), title
INTO employees_per_title_retiring
FROM partitioned_retiring_emp_by_title AS pret
GROUP BY pret.title
ORDER BY pret.title;

--- List of current employees born in 1965
-- Join emp_info with salaries data
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	ti.title,
	de.from_date,
	de.to_date
INTO Mentor_Eligibility
FROM employees AS e
INNER JOIN titles AS ti
ON (e.emp_no = ti.emp_no)
INNER JOIN dept_emp AS de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	 AND (de.to_date = '9999-01-01');

-- Determine if there are duplicates in Mentor Eligibility table, 
-- to see if a partition is necessary, by comparing unique records with 
-- the number of records in Mentor_Eligibility
SELECT COUNT (DISTINCT (emp_no)) FROM Mentor_Eligibility;

-- Partition the data to show only most recent title per employee mentor
SELECT tmp.emp_no,
	tmp.first_name,
	tmp.last_name,
	tmp.title,
	tmp.from_date,
	tmp.to_date
INTO Partitioned_Mentor_Eligibility
FROM 
 (SELECT emp_no,
first_name,
last_name,
  title,
from_date,
to_date, 
  ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM Mentor_Eligibility
 ) tmp WHERE rn = 1
ORDER BY emp_no;