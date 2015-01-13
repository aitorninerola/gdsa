CREATE TABLE IF NOT EXISTS trainset(
    document_id VARCHAR(255) NOT NULL PRIMARY KEY,
    user varchar(255),
    tags TEXT,
    coord varchar(255),
    data varchar(355),
    classe VARCHAR(20),
    FULLTEXT (user,tags,coord,data)
) ENGINE=InnoDB;
