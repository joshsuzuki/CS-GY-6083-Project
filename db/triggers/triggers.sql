CREATE TRIGGER after_employee_fired
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.current_employee = FALSE THEN
        DELETE FROM employees_groups WHERE employee_id = NEW.id;
    END IF;
END;