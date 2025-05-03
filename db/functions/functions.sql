DROP function IF EXISTS salary_difference$$
create function salary_difference(emp_id INT) RETURNS DECIMAL(18,2)
DETERMINISTIC
BEGIN
    DECLARE current_salary DECIMAL(18,2);
    DECLARE previous_salary DECIMAL(18,2);
    
    SELECT salary INTO current_salary FROM employees WHERE id = emp_id;
    
    SELECT old_salary INTO previous_salary
    FROM salary_history
    WHERE employee_id = emp_id
    ORDER BY change_date DESC
    LIMIT 1;
    
    RETURN IFNULL(current_salary - previous_salary, 0);
END$$
delimiter ;