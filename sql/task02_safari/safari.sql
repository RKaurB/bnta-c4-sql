-- ******************************* --
--      CLEAR EXISTING TABLE(S)    --
-- ******************************* --

DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS enclosure CASCADE;
DROP TABLE IF EXISTS assignment CASCADE;
DROP TABLE IF EXISTS animal CASCADE;


-- ******************************* --
--           CREATE TABLES     	   --
-- ******************************* --

CREATE TABLE staff (
staff_id SERIAL PRIMARY KEY,
name VARCHAR(255),
employee_number INT
);

CREATE TABLE enclosure (
enclosure_id SERIAL PRIMARY KEY,
enclosure_name VARCHAR(255),
capacity INT,
closedForMaintenance BOOLEAN
);

CREATE TABLE assignment (
assignment_id SERIAL PRIMARY KEY,
staff_id INT REFERENCES staff(staff_id),
enclosure_id INT REFERENCES enclosure(enclosure_id),
assignment_day VARCHAR(255)
);

CREATE TABLE animal (
animal_id SERIAL PRIMARY KEY,
name VARCHAR(255),
type VARCHAR(255) NOT NULL,
age INT,
enclosure_id INT REFERENCES enclosure(enclosure_id)
);


-- ******************************* --
--            INSERT DATA          --
-- ******************************* --

-- Staff table data
INSERT INTO staff(name, employee_number) VALUES
	('Michael', 001),
	('Abdi', 002),
	('Rachel', 003), 
	('Hajr', 004),
	('Suad', 005),
	('Michelle', 006);

-- Enclosure table data
INSERT INTO enclosure(enclosure_name, capacity, closedForMaintenance) VALUES
	('The Big Cat Park', 15, FALSE),
	('The Lions Den', 7, FALSE),
	('Hungry Hippos', 4, TRUE),
	('The Loud Trees', 18, FALSE);
	
-- Animals table data
INSERT INTO animal(name, type, age, enclosure_id) VALUES 
	('Griff','Tiger', 35, 1),
	('Tony','Tiger', 34, 1),
	('Caroline','Lion', 25, 2),
	('Arnold','Lion', 30, 2),
	('Elena','Hippo', 41, 3),
	('Smithy','Gorilla', 41, 4),
	('Sarah','Gorilla', 28, 4),
	('Baby', 'Gorilla', 1, 4);

-- Assignments table data
INSERT INTO assignment (staff_id, enclosure_id, assignment_day) VALUES
	(001, 1, 'Monday'),
	(001, 1, 'Tuesday'),
	(001, 1, 'Wednesday'),
	(002, 1, 'Thursday'),
	(002, 1, 'Friday'),
	(003, 1, 'Saturday'),
	(003, 1, 'Sunday'),

	(002, 2, 'Monday'),
	(002, 2, 'Tuesday'),
	(002, 2, 'Wednesday'),
	(001, 2, 'Thursday'),
	(001, 2, 'Friday'),
	(001, 2, 'Saturday'),
	(004, 2, 'Sunday'),
	
	(004, 3, 'Monday'),
	(004, 3, 'Tuesday'),
	(004, 3, 'Wednesday'),
	(004, 3, 'Thursday'),
	(005, 3, 'Friday'),
	(005, 3, 'Saturday'),
	(005, 3, 'Sunday'),

	(005, 4, 'Monday'),
	(005, 4, 'Tuesday'),
	(006, 4, 'Wednesday'),
	(006, 4, 'Thursday'),
	(006, 4, 'Friday'),
	(006, 4, 'Saturday'),
	(006, 4, 'Sunday');
	

-- ******************************* --
--              QUERIES            --
-- ******************************* --


/* 1. Find the names of the animals in a given enclosure. */

-- Select animal name(s) from the animal table
SELECT animal.name 
FROM animal
-- join with the enclosure table, where PK matches the FK (enclosure IDs) in the animals table
INNER JOIN enclosure
ON enclosure.enclosure_id = animal.enclosure_id
-- and where either the enclosure is ID = 1 or name = 'The Loud Trees';
WHERE enclosure.enclosure_id = 1 OR enclosure.enclosure_name = 'The Loud Trees';

-- This works the same as the above, but instead returns 3 named columns - Enclosure ID and name, and the animal
SELECT enclosure.enclosure_id as "Enclosure ID", enclosure.enclosure_name as "Enclosure", animal.name as "Animal" 
FROM animal
INNER JOIN enclosure
ON animal.enclosure_id = enclosure.enclosure_id
WHERE enclosure.enclosure_id = 1 OR enclosure.enclosure_name = 'The Loud Trees';


/* 2. Find the names of the staff working in a given enclosure. */

-- Select staff names from the staff table
SELECT DISTINCT staff.name 
FROM staff
-- and join with the assignment table, where staff ID matches the staff ID in the staff table 
INNER JOIN assignment
ON assignment.staff_id = staff.staff_id
WHERE assignment.enclosure_id = 1;


/* 3. Find the names of staff working in enclosures which are closed for maintenance. */
SELECT DISTINCT staff.name 
FROM staff
INNER JOIN assignment
ON assignment.staff_id = staff.staff_id
INNER JOIN enclosure
ON enclosure.enclosure_id = assignment.enclosure_id
WHERE enclosure.closedformaintenance IS TRUE;


/* 4. Find the name of the enclosure where the oldest animal lives. 
If there are two animals who are the same age choose the first one alphabetically. */
SELECT enclosure.enclosure_name as "Enclosure", animal.name as "Animal"
FROM animal
INNER JOIN enclosure
ON animal.enclosure_id = enclosure.enclosure_id
WHERE animal.age = (SELECT MAX(animal.age) FROM animal)
ORDER BY animal.name ASC LIMIT 1;


/* 5. Find the number of different animal types a given keeper has been assigned to work with. */
SELECT COUNT(DISTINCT animal.type)
FROM animal
INNER JOIN enclosure
ON animal.enclosure_id = enclosure.enclosure_id
INNER JOIN assignment
ON assignment.enclosure_id = enclosure.enclosure_id
WHERE assignment.staff_id = 3;


/* 6. Find the number of different keepers who have been assigned to work in a given enclosure. */
SELECT COUNT(DISTINCT staff.name)
FROM staff
INNER JOIN assignment
ON assignment.staff_id = staff.staff_id
WHERE assignment.enclosure_id = 4;


/* 7. The names of the other animals sharing an enclosure with a given animal (eg. find the names of all the animals sharing the big cat field with Tony) */
SELECT animal.name FROM animal
INNER JOIN enclosure ON enclosure.enclosure_id = animal.enclosure_id
WHERE enclosure.enclosure_id = 
	(SELECT animal.enclosure_id 
	FROM animal 
	WHERE animal.name = 'Tony')
AND animal.name = 'Tony' IS FALSE;

--SELECT animal.name 
--FROM animal
--INNER JOIN enclosure ON enclosure.enclosure_id = animal.enclosure_id
--WHERE animal.name = 'Tony';


