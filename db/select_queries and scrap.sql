USE project_db;

select * from vw_balance_by_qtr;
select * from employees where id = 3;
select * from employee_auth;

select * from vw_employee_entity;

select * from employees;

select * from tbl_entities;
select * from tbl_groups;
select * from employees_groups;
select * from salary_history;
select * from groups_entities;
select salary_difference(1);
select * from vw_employee_entity;


delete from balances_stage;
select * from balances;
select * from balances_stage;
select * from vw_employee_entity where entity_id = 9;

select * from balances_stage where entity = 9;
SELECT bs.account, bs.entity, bs.counterparty, bs.month, bs.year, bs.amount, 3 AS n_id_updated_by
    FROM balances_stage bs
    INNER JOIN vw_employee_entity vee ON bs.entity = vee.entity_id
    WHERE vee.id = 3
    AND bs.operation = '\'merge\'';

select bal.*
from balances bal
join vw_employee_entity vee on bal.entity = vee.entity_id
where vee.id = ?

select * from vw_salaries_by_group;
select * from vw_balance_by_qtr;

