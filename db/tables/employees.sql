DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    salary DECIMAL(18,2) DEFAULT 0,
    current_employee BOOLEAN DEFAULT TRUE,
    hire_date DATETIME DEFAULT NOW()
);
