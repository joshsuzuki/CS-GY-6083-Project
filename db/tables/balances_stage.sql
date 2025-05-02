DROP TABLE IF EXISTS balances_stage;
CREATE TABLE balances (
    account INT NOT NULL,
    entity INT NOT NULL,
    counterparty INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    amount DECIMAL(18,2) DEFAULT 0,
    n_id_updated_by INT NOT NULL,
    dt_last_updated DATETIME DEFAULT NOW(),
    PRIMARY KEY (account, entity, counterparty,month,year)
);
