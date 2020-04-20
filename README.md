# Pewlett_Hackard_Analysis

# Pewlett_Hackard Challenge

**In your first paragraph, introduce the problem that you were using data to solve.

Problem description: 
Using the PH employee database I have previously created, create additional tables to describe the number of employees who are retiring, ordering them by title, then further explore how many employees of certain titles are retiring.  This may show that potential leadership holes are being created. Retiring employees are defined by age, as having been born in the four years 1952 to 1955.  If leadership holes are created, ie too many senior level employees with the same title retiring at once, then we need to explore whom at the company could mentor younger employees.  Potential mentors are defined by age, and for this purpose, were those who were born in 1965.

**In your second paragraph, summarize the steps that you took to solve the problem, as well as the challenges that you encountered along the way. This is an excellent spot to provide examples and descriptions of the code that you used.  **Full code of challenge plus selected code of module is pasted at the bottom of the ReadMe**

First, I set about determining the titles of employees who are expected to retire, using the previously-created table retirement_info (the flow of this process is in the ERD below).  Considering these are the most senior people in the organization, it is likely they have had multiple titles and may be counted more than once.  So, I checked, using SELECT * FROM retiring_emp_by_title;, and there were duplicates, nearly double, at over 65,000 entries vs 41,380 unique retirees.  Therefore, I used partition to get only the unique retirees, and then I re-ordered the table called partitioned_retiring_emp_by_title, by title, so you can look down the table by titles.  You can see the join code at the end of this README.  Here, I show the partition code, as a sample:

-- Partition the data to show only most recent title per employee, which will remove duplicates to create final table
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

Then I created a table showing by title, the number of employees retiring.  This is interesting because it shows whether there may be a significant strain in a certain type of employee, either by level or function, so that management can make appropriate plans.  This leads us to the third table, which is created because if management sees areas where holes may be created by too many people in one title retiring, we are then anticipating that they will want to know who could mentor the next level of employee to fill those holes.

To determine whom might be an eligible mentor, I first created a list of current employees born in 1965 by joining emp_info with salaries table.  However, I needed to see if there were any duplicates, as employees might have moved around.  I did this by using COUNT DISTINCT(), and indeed there were duplicates, so I proceeded to partition the data in much the same way I did above for retiring employees.  This gave a list of the number of unique employees with their most recent title, born in 1965 who then would be considered eligible to be a mentor.


**In your final paragraph, share the results of your analysis and discuss the data that you’ve generated. Have you identified any limitations to the analysis? What next steps would you recommend?

There are 41,380 employees eligible for retirement, defined as having been born in the years 1952, 1953, 1954 or 1955.  When grouped by title, we can see the greatest need for mentoring is likely in the engineering department.  Here is a list of the number of employees retiring by title:

Number of Retiring Employees    Title
             501	              Assistant Engineer
           4,693	              Engineer	
               2	              Manager	
          15,599	              Senior Engineer
          14,735	              Senior Staff
           3,837	              Staff	
           2,013	              Technique Leader

You can see that of the 41,380 employees eligible for retirement, 38% are senior engineers, and when you include engineers and senior engineers, this brings us to 49% of total retirees.  Of course, we would need more data as to the total bench of engineers and senior engineers, to know what percentage of each title are leaving to fully understand the issue.  Often engineers specialize in one area, so we would need to understand if we are losing more engineers as a percentage from certain areas.  36% of eligible retirees are senior staff, which arguably may be easier to mentor, but we would need more details as to what this title means.  As to Mentors, there are 1,549 employees born in the year 1965.  I assume I was asked for this data to access older employees, but these are not necessarily the most senior employees.  Using this data, we can see there are 290 senior engineers who are born in 1965, and 415 senior staff born in 1965.  Therefore, there will be a much bigger burden on engineers with 31% fewer senior engineers vs senior staff available as mentors, and more senior engineers retiring.  Another way to look at it, is that if these 290 senior engineers mentored others to fill those spots, they would be helping bridge the gap for 54 spots each, ie 54 senior engineers are retiring for every senior engineer who is working at PH and born in 1965.

I recommend that management:
(1)	Further look at what specific projects are losing engineers and the percentage loss of engineers by project and seniority within that project
(2)	Further explore the actual duties of all the “Senior Staff” to determine the roles that may need mentoring and also if certain areas or functions withing the company, for instance finance, are losing disproportionate staff, to determine mentorship needs.
(3)	After considering the above, perhaps ask certain employees to delay their retirement such that the company has more time to mentor and train.
(4)	For the mentoring portion, I recommend that management widen the age group of mentors beyond just one year, and also do a sort based on seniority and title, especially now we can see that senior engineers is an area of need.  Some people who are younger may be more senior and vice versa.
(5)	Finally, I recommend doing a more granular search for mentors based on the projects they are working on, so that the projects who are losing the most employees to retirement can be matched with mentors in either adjacent projects or their work within their own project can be pared back if they are expected to be in a project where a number of senior engineers are retiring.

**Here are the three csv tables:

Retiring employees sorted by their title:

![Partitioned_retiring_emp_by_title](https://github.com/emmysobieski/Pewlett_Hackard_Analysis/blob/master/Data/Partitioned_retiring_emp_by_title.csv)


Number of employees retiring in each title:

![employees_per_title_retiring](https://github.com/emmysobieski/Pewlett_Hackard_Analysis/blob/master/Data/employees_per_title_retiring.csv)

Number of employees born in 1965 eligible to mentor:

![Partitioned_Mentor_Eligibility](https://github.com/emmysobieski/Pewlett_Hackard_Analysis/blob/master/Data/Partitioned_Mentor_Eligibility.csv)

Here is a copy of the ERD I created when mapping out the database to link in retirement_info:


![](https://github.com/emmysobieski/Pewlett_Hackard_Analysis/blob/master/ERD_Challenge.png) 



-----------------------------------------------------------------------------------------------------

**Below are pieces of the code used from the module, creating tables, along with the full code of the challenge:

-- Creating tables for PH-EmployeeDB

CREATE TABLE employees (
	emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no));

CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no));

CREATE TABLE "dept_emp" (
    "emp_no" INT   NOT NULL,
    "dept_no" VARCHAR(4)   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    CONSTRAINT "pk_Dept_Emp" PRIMARY KEY (
        "emp_no","dept_no"));

CREATE TABLE "titles" (
    "emp_no" INT   NOT NULL,
    "title" VARCHAR  NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
    CONSTRAINT "pk_Titles" PRIMARY KEY (
        "emp_no","title","from_date"));

-- Create new table for potentially retiring employees (THIS retirement_info TABLE IS IN THE “ERD Challenge”, linked to employee table, which further links to salary and title tables.)

SELECT emp_no, first_name, last_name
INTO retirement_info  
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

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
