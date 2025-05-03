DELIMITER $$
DROP PROCEDURE IF EXISTS sp_validate_and_merge_to_balance$$
CREATE PROCEDURE sp_validate_and_merge_to_balance(IN emp_id INT)
BEGIN
    -- Temp merge table
    CREATE TEMPORARY TABLE temp_merge AS
    SELECT bs.account, bs.entity, bs.counterparty, bs.month, bs.year, bs.amount, emp_id AS n_id_updated_by
    FROM balances_stage bs
    INNER JOIN vw_employee_entity vee ON bs.entity = vee.entity
    WHERE vee.employee_id = emp_id
    AND bs.operation = 'merge';

    -- Temp delete table
    CREATE TEMPORARY TABLE temp_delete AS
    SELECT bs.account, bs.entity, bs.counterparty, bs.month, bs.year AS n_id_updated_by
    FROM balances_stage bs
    INNER JOIN vw_employee_entity vee ON bs.entity = vee.entity
    WHERE vee.employee_id = emp_id
    AND bs.operation = 'delete';

    -- Delete from balances table
    DELETE FROM balances
    WHERE (account, entity, counterparty, month, year) IN (
        SELECT account, entity, counterparty, month, year FROM temp_delete
    );

    -- Merge data into balances table
    INSERT INTO balances (account, entity, counterparty, month, year, amount, n_id_updated_by, dt_last_updated)
    SELECT account, entity, counterparty, month, year, amount, n_id_updated_by, NOW() FROM temp_merge
    ON DUPLICATE KEY UPDATE
        n_id_updated_by = emp_id,
        dt_last_updated = NOW(),
        amount = VALUES(amount);

END $$

DELIMITER ;