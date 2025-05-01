CREATE TRIGGER after_employee_fired
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.current_employee = FALSE THEN
        DELETE FROM employees_groups WHERE employee_id = NEW.id;
    END IF;
END;

CREATE TRIGGER after_employee_created
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_auth (employee_id, password_hash)
    VALUES (NEW.id, SHA2('default', 256));
END;
