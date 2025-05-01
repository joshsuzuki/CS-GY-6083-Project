DROP TABLE IF EXISTS employee_auth;

CREATE TABLE employee_auth (
    employee_id INT PRIMARY KEY,
    password_hash VARCHAR(255) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
);
