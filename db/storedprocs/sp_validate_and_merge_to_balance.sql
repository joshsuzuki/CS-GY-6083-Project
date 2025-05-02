DELIMITER //

CREATE PROCEDURE sp_validate_and_merge_to_balance(IN emp_id INT)
BEGIN
    -- Create a temporary table to hold the joined data
    CREATE TEMPORARY TABLE temp_merged AS
    SELECT bs.account, bs.entity, bs.counterparty, bs.month, bs.year, bs.amount, emp_id AS n_id_updated_by
    FROM balances_stage bs
    INNER JOIN view_employee_entity vee ON bs.entity = vee.entity
    WHERE vee.employee_id = emp_id;

    -- Merge data into balances table
    INSERT INTO balances (account, entity, counterparty, month, year, amount, n_id_updated_by, dt_last_updated)
    SELECT account, entity, counterparty, month, year, amount, n_id_updated_by, NOW() FROM temp_merged
    ON DUPLICATE KEY UPDATE
        n_id_updated_by = VALUES(n_id_updated_by),
        dt_last_updated = NOW(),
        amount = VALUES(amount);

END //

DELIMITER ;