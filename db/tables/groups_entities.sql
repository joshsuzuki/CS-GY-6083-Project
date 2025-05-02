DROP TABLE IF EXISTS groups_entities;

CREATE TABLE groups_entities (
    group_id INT NOT NULL,
    entity INT NOT NULL,
    permission VARCHAR(50) NOT NULL,
    PRIMARY KEY (group_id, entity),
    FOREIGN KEY (group_id) REFERENCES tbl_groups(group_id) ON DELETE CASCADE
);
