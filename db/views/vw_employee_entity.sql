CREATE VIEW vw_employee_entity AS
SELECT e.id, ge.entity
FROM employees e
JOIN employee_groups eg ON e.id = eg.employee_id
JOIN group_entities ge ON eg.group_id = ge.group_id;