CREATE VIEW vw_salaries_by_group AS
SELECT g.group_name, SUM(e.salary) AS total_salary
FROM employees e
JOIN employee_groups eg ON e.id = eg.employee_id
JOIN tbl_groups g ON eg.group_id = g.group_id
GROUP BY g.group_name;