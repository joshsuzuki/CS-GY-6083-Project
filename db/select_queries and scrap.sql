USE project_db;

select * from employees;
select * from employee_auth;
select * from tbl_groups;
select * from tbl_entities;

select * from employees_groups;
select * from groups_entities;
select * from vw_employee_entity;


select * from salary_history;
select salary_difference(4);


delete from balances_stage;
select * from balances;
select * from balances_stage;

-- AGGREGATED VIEWS
select * from vw_salaries_by_group;
select * from vw_balance_by_qtr;

