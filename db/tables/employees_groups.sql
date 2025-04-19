DROP TABLE IF EXISTS employees_groups;

CREATE TABLE employees_groups (
    group_id INT NOT NULL,
    employee_id NT NOT NULL,
    PRIMARY KEY (group_id, employee_id)
);
