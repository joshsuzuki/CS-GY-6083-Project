DROP TABLE IF EXISTS groups_entities;

CREATE TABLE groups_entities (
    group_id INT NOT NULL,
    entity_id INT NOT NULL,
    PRIMARY KEY (group_id, entity),
    FOREIGN KEY (group_id) REFERENCES tbl_groups(group_id) ON DELETE CASCADE,
    FOREIGN KEY (entity_id) REFERENCES tbl_entities(entity_id) ON DELETE CASCADE
);
