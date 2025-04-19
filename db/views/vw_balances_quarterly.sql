DROP VIEW IF EXISTS vw_balance_by_qtr;
CREATE VIEW vw_balance_by_qtr
AS
SELECT account,entity,counterparty,CASE 
        WHEN month IN (1, 2, 3) THEN 'Q1'
        WHEN month IN (4, 5, 6) THEN 'Q2'
        WHEN month IN (7, 8, 9) THEN 'Q3'
        WHEN month IN (10, 11, 12) THEN 'Q4'
    END AS quarter,
    SUM(amount) AS quartely_amount
FROM balances
GROUP BY account,entity,counterparty,CASE 
        WHEN month IN (1, 2, 3) THEN 'Q1'
        WHEN month IN (4, 5, 6) THEN 'Q2'
        WHEN month IN (7, 8, 9) THEN 'Q3'
        WHEN month IN (10, 11, 12) THEN 'Q4';
