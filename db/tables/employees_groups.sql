CREATE TABLE employees_groups (
    employee_id INT NOT NULL,
    group_id INT NOT NULL,
    PRIMARY KEY (group_id, employee_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES groups(group_id) ON DELETE CASCADE
);
