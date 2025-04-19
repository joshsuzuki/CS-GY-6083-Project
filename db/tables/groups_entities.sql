DROP TABLE IF EXISTS groups_entities;

CREATE TABLE groups_entities (
    group_id INT NOT NULL,
    entity INT NOT NULL,
    PRIMARY KEY (group_id, entity)
);
