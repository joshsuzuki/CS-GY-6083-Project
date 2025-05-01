DROP DATABASE IF EXISTS project_db;
CREATE DATABASE project_db;
USE project_db;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    salary DECIMAL(18,2) DEFAULT 0,
    current_employee BOOLEAN DEFAULT TRUE,
    hire_date DATETIME DEFAULT NOW()
);

DROP TABLE IF EXISTS employee_auth;

CREATE TABLE employee_auth (
    employee_id INT PRIMARY KEY,
    password_hash VARCHAR(255) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
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

DROP TABLE IF EXISTS employees_groups;

CREATE TABLE employees_groups (
    group_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (group_id, employee_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES tbl_groups(group_id) ON DELETE CASCADE
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

CREATE TRIGGER after_employee_fired
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.current_employee = FALSE THEN
        DELETE FROM employees_groups WHERE employee_id = NEW.id;
    END IF;
END$$
DELIMITER ;

INSERT INTO employees (first_name, last_name)
VALUES ('josh','s');

INSERT INTO employees (first_name, last_name)
VALUES ('john','m');

INSERT INTO balances (account, entity, counterparty, month, year, amount, n_id_updated_by)
VALUES
(1, 1, 1, 1, 2023, 1000.00, 1),
(1, 1, 1, 2, 2023, 2000.00, 1),
(1, 1, 1, 3, 2023, 3000.00, 1),
(4, 2, 4, 4, 2023, 4000.00, 1),
(5, 3, 5, 5, 2023, 5000.00, 1);
