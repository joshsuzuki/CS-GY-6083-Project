DROP DATABASE IF EXISTS project_db;
CREATE DATABASE project_db;
USE project_db;

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
    n_id_updated_by INT NOT NULL,
    operation VARCHAR(10) NOT NULL,
    PRIMARY KEY (account, entity, counterparty,month,year)
);

DROP TABLE IF EXISTS employees_groups;
CREATE TABLE employees_groups (
    group_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (group_id, employee_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES tbl_groups(group_id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS groups_entities;
CREATE TABLE groups_entities (
    group_id INT NOT NULL,
    entity_id INT NOT NULL,
    permission VARCHAR(50) NOT NULL,
    PRIMARY KEY (group_id, entity_id),
    FOREIGN KEY (group_id) REFERENCES tbl_groups(group_id) ON DELETE CASCADE,
    FOREIGN KEY (entity_id) REFERENCES tbl_entities(entity_id) ON DELETE CASCADE
);

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
END$$

-- Stored Procedure ----------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_validate_and_merge_to_balance$$
CREATE PROCEDURE sp_validate_and_merge_to_balance(IN emp_id INT)
BEGIN
    -- Temp merge table
    CREATE TEMPORARY TABLE temp_merge AS
    SELECT bs.account, bs.entity, bs.counterparty, bs.month, bs.year, bs.amount, emp_id AS n_id_updated_by
    FROM balances_stage bs
    INNER JOIN vw_employee_entity vee ON bs.entity = vee.entity
    WHERE vee.employee_id = emp_id
    AND bs.operation = 'merge';

    -- Temp delete table
    CREATE TEMPORARY TABLE temp_delete AS
    SELECT bs.account, bs.entity, bs.counterparty, bs.month, bs.year AS n_id_updated_by
    FROM balances_stage bs
    INNER JOIN vw_employee_entity vee ON bs.entity = vee.entity
    WHERE vee.employee_id = emp_id
    AND bs.operation = 'delete';

    -- Delete from balances table
    DELETE FROM balances
    WHERE (account, entity, counterparty, month, year) IN (
        SELECT account, entity, counterparty, month, year FROM temp_delete
    );

    -- Merge data into balances table
    INSERT INTO balances (account, entity, counterparty, month, year, amount, n_id_updated_by, dt_last_updated)
    SELECT account, entity, counterparty, month, year, amount, n_id_updated_by, NOW() FROM temp_merge
    ON DUPLICATE KEY UPDATE
        n_id_updated_by = emp_id,
        dt_last_updated = NOW(),
        amount = VALUES(amount);

END $$
DELIMITER ;

-- Inserts ----------------------------------------------------------------------------
INSERT INTO employees (first_name, last_name)
VALUES ('josh','s');

INSERT INTO employees (first_name, last_name)
VALUES ('john','m');

INSERT INTO employee_auth(employee_id,password_hash)
VALUES
(1,'$2y$12$VwaHReZde1zNoCrZdH2uBuSuXGMlqJLRW1w0ytO8FOvIrG66RoDhO'),
(2,'$2y$12$VwaHReZde1zNoCrZdH2uBuSuXGMlqJLRW1w0ytO8FOvIrG66RoDhO');

INSERT INTO tbl_entities(entity_name)
VALUES
('Finance 1'),('Finance 2'),('Finance 3'),('Finance 4'),
('HR 1'),('HR 2'),('HR 3'),('HR 4'),
('Tech 1'),('Tech 2'),('Tech 3'),('Tech 4');


INSERT INTO balances (account, entity, counterparty, month, year, amount, n_id_updated_by)
VALUES
(1, 1, 1, 1, 2023, 1000.00, 1),
(1, 1, 1, 2, 2023, 2000.00, 1),
(1, 1, 1, 3, 2023, 3000.00, 1),
(4, 2, 4, 4, 2023, 4000.00, 1),
(5, 3, 5, 5, 2023, 5000.00, 1);
