DROP DATABASE IF EXISTS project_db;
CREATE DATABASE project_db;
USE project_db;
SET SQL_SAFE_UPDATES = 0;
-- Tables ------------------------------------------------------------
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    salary DECIMAL(18,2) DEFAULT 0,
    current_employee BOOLEAN DEFAULT TRUE,
    hire_date DATETIME DEFAULT NOW()
);

DROP TABLE IF EXISTS salary_history;
CREATE TABLE salary_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    old_salary DECIMAL(10,2) NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

DROP TABLE IF EXISTS employee_auth;
CREATE TABLE employee_auth (
    employee_id INT PRIMARY KEY,
    password_hash VARCHAR(255) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS tbl_entities;

CREATE TABLE tbl_entities (
    entity_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS tbl_groups;
CREATE TABLE tbl_groups (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS balances;
CREATE TABLE balances (
    account INT NOT NULL,
    entity INT NOT NULL,
    counterparty INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    amount DECIMAL(18,2) DEFAULT 0,
    n_id_updated_by INT NOT NULL,
    dt_last_updated DATETIME DEFAULT NOW(),
    PRIMARY KEY (account, entity, counterparty,month,year)
);

DROP TABLE IF EXISTS balances_stage;
CREATE TABLE balances_stage (
    account INT NOT NULL,
    entity INT NOT NULL,
    counterparty INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    amount DECIMAL(18,2) DEFAULT 0,
    operation VARCHAR(10) NOT NULL,
    PRIMARY KEY (account, entity, counterparty,month,year)
);

DROP TABLE IF EXISTS employees_groups;
CREATE TABLE employees_groups (
    employee_id INT NOT NULL,
    group_id INT NOT NULL,
    PRIMARY KEY (group_id, employee_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES tbl_groups(group_id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS groups_entities;
CREATE TABLE groups_entities (
    group_id INT NOT NULL,
    entity_id INT NOT NULL,
    PRIMARY KEY (group_id, entity_id),
    FOREIGN KEY (group_id) REFERENCES tbl_groups(group_id) ON DELETE CASCADE,
    FOREIGN KEY (entity_id) REFERENCES tbl_entities(entity_id) ON DELETE CASCADE
);

-- Views ----------------------------------------------------------------
DROP VIEW IF EXISTS vw_balance_by_qtr;
CREATE VIEW vw_balance_by_qtr
AS
SELECT account,entity,counterparty,CASE 
        WHEN month IN (1, 2, 3) THEN 'Q1'
        WHEN month IN (4, 5, 6) THEN 'Q2'
        WHEN month IN (7, 8, 9) THEN 'Q3'
        WHEN month IN (10, 11, 12) THEN 'Q4'
    END AS quarter,
    SUM(amount) AS quartely_amount
FROM balances
GROUP BY account,entity,counterparty,CASE 
        WHEN month IN (1, 2, 3) THEN 'Q1'
        WHEN month IN (4, 5, 6) THEN 'Q2'
        WHEN month IN (7, 8, 9) THEN 'Q3'
        WHEN month IN (10, 11, 12) THEN 'Q4' END;

DROP VIEW IF EXISTS vw_employee_entity;
CREATE VIEW vw_employee_entity AS
SELECT e.id, ge.entity_id
FROM employees e
JOIN employees_groups eg ON e.id = eg.employee_id
JOIN groups_entities ge ON eg.group_id = ge.group_id;

DROP VIEW IF EXISTS vw_salaries_by_group;
CREATE VIEW vw_salaries_by_group AS
SELECT g.group_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN employees_groups eg ON e.id = eg.employee_id
JOIN tbl_groups g ON eg.group_id = g.group_id
GROUP BY g.group_name;

DELIMITER $$
-- Function ------------------------------------------------------------
DROP function IF EXISTS salary_difference$$
create function salary_difference(emp_id INT) RETURNS DECIMAL(18,2)
DETERMINISTIC
BEGIN
    DECLARE current_salary DECIMAL(18,2);
    DECLARE previous_salary DECIMAL(18,2);
    
    SELECT salary INTO current_salary FROM employees WHERE id = emp_id;
    
    SELECT old_salary INTO previous_salary
    FROM salary_history
    WHERE employee_id = emp_id
    ORDER BY change_date DESC
    LIMIT 1;
    
    RETURN IFNULL(current_salary - previous_salary, 0);
END$$

-- Triggers ------------------------------------------------------------
CREATE TRIGGER after_employee_fired
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.current_employee = FALSE THEN
        DELETE FROM employees_groups WHERE employee_id = NEW.id;
    END IF;
END$$

CREATE TRIGGER salary_update_trigger
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO salary_history (employee_id, old_salary)
    VALUES (OLD.id, OLD.salary);
END $$

CREATE TRIGGER remove_single_quotes_before_insert
BEFORE INSERT ON balances_stage
FOR EACH ROW
BEGIN
    SET NEW.operation = REPLACE(NEW.operation, "'", "");
END $$

CREATE TRIGGER after_insert_tbl_entities
AFTER INSERT ON tbl_entities
FOR EACH ROW
BEGIN
    INSERT INTO groups_entities (group_id, entity_id)
    VALUES (4, NEW.entity_id);
END $$
-- Stored Procedure ----------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_validate_and_merge_to_balance$$
CREATE PROCEDURE sp_validate_and_merge_to_balance(IN emp_id INT)
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    -- Temp merge table
    CREATE TEMPORARY TABLE temp_merge AS
    SELECT bs.account, bs.entity, bs.counterparty, bs.month, bs.year, bs.amount, emp_id AS n_id_updated_by
    FROM balances_stage bs
    INNER JOIN vw_employee_entity vee ON bs.entity = vee.entity_id
    WHERE vee.id = emp_id
    AND bs.operation = 'merge';

    -- Temp delete table
    CREATE TEMPORARY TABLE temp_delete AS
    SELECT bs.account, bs.entity, bs.counterparty, bs.month, bs.year AS n_id_updated_by
    FROM balances_stage bs
    INNER JOIN vw_employee_entity vee ON bs.entity = vee.entity_id
    WHERE vee.id = emp_id
    AND bs.operation = 'delete';

    -- Delete from balances table
    DELETE FROM balances
    WHERE (account, entity, counterparty, month, year) IN (
        SELECT account, entity, counterparty, month, year FROM temp_delete
    );
    DROP TEMPORARY TABLE temp_delete;

    -- Merge data into balances table
    INSERT INTO balances (account, entity, counterparty, month, year, amount, n_id_updated_by, dt_last_updated)
    SELECT account, entity, counterparty, month, year, amount, n_id_updated_by, NOW() FROM temp_merge
    ON DUPLICATE KEY UPDATE
        n_id_updated_by = emp_id,
        dt_last_updated = NOW(),
        amount = VALUES(amount);
    DROP TEMPORARY TABLE temp_merge;
    
    DELETE FROM balances_stage;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
END $$
DELIMITER ;

-- DML -------------------------------------------------------------------------------
-- Inserts ----------------------------------------------------------------------------
INSERT INTO employees (first_name, last_name)
VALUES ('Freddy','Finance');

INSERT INTO employees (first_name, last_name)
VALUES ('Harry','HR');

INSERT INTO employees (first_name, last_name)
VALUES ('Timmy','Tech');

INSERT INTO employees (first_name, last_name)
VALUES ('Diane','Dev');


INSERT INTO employee_auth(employee_id,password_hash)
VALUES
(1,'$2y$12$VwaHReZde1zNoCrZdH2uBuSuXGMlqJLRW1w0ytO8FOvIrG66RoDhO'),
(2,'$2y$12$VwaHReZde1zNoCrZdH2uBuSuXGMlqJLRW1w0ytO8FOvIrG66RoDhO'),
(3,'$2y$12$VwaHReZde1zNoCrZdH2uBuSuXGMlqJLRW1w0ytO8FOvIrG66RoDhO'),
(4,'$2y$12$VwaHReZde1zNoCrZdH2uBuSuXGMlqJLRW1w0ytO8FOvIrG66RoDhO');

INSERT INTO tbl_groups(group_name)
VALUES
('Finance'),('H2'),('Tech'),('Developer');

INSERT INTO tbl_entities(entity_name)
VALUES
('Finance 1'),('Finance 2'),('Finance 3'),('Finance 4'),
('HR 1'),('HR 2'),('HR 3'),('HR 4'),
('Tech 1'),('Tech 2'),('Tech 3'),('Tech 4');



INSERT INTO groups_entities(group_id,entity_id)
VALUES
(1,1),(1,2),(1,3),(1,4),
(2,5),(2,6),(2,7),(2,8),
(3,9),(3,10),(3,11),(3,12);

INSERT INTO employees_groups(employee_id,group_id)
VALUES
(1,1),(2,2),(3,3),(4,4);

-- Updates ---------------------------------------------------------------------
UPDATE employees
SET salary = 100000
WHERE id = 1;

UPDATE employees
SET salary = 110000
WHERE id = 1;

UPDATE employees
SET salary = 130000
WHERE id = 1;

UPDATE employees
SET salary = 110000
WHERE id = 2;

UPDATE employees
SET salary = 130000
WHERE id = 3;

UPDATE tbl_entities
SET entity_name = 'Finance 11'
WHERE entity_id = 1;

UPDATE tbl_groups
SET group_name = 'Financial'
WHERE group_id = 1;

