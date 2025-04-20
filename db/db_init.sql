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

DROP TABLE IF EXISTS groups;

CREATE TABLE groups (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL,
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
    FOREIGN KEY (group_id) REFERENCES groups(group_id) ON DELETE CASCADE
);
