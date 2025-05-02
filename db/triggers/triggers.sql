CREATE TRIGGER after_employee_fired
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.current_employee = FALSE THEN
        DELETE FROM employees_groups WHERE employee_id = NEW.id;
    END IF;
END;

-- CREATE TRIGGER after_employee_created
-- AFTER INSERT ON employees
-- FOR EACH ROW
-- BEGIN
--     INSERT INTO employee_auth (employee_id, password_hash)
--     VALUES (NEW.id, '$2y$12$VwaHReZde1zNoCrZdH2uBuSuXGMlqJLRW1w0ytO8FOvIrG66RoDhO');
-- END;
