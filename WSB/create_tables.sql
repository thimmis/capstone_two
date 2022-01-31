--This table is to collect the post data that has not been deleted or removed by mods.
CREATE TABLE posts (
    id TEXT NOT NULL,
    dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    mentions TEXT,
    body TEXT,
    link TEXT,
    PRIMARY KEY (id, dt)
);

CREATE TABLE comments (
    id TEXT NOT NULL,
    post_id TEXT NOT NULL,
    parent_id TEXT,
    dt TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    is_op BOOLEAN NOT NULL,
    author TEXT NOT NULL,
    body TEXT,
    PRIMARY KEY (id, dt),
    CONSTRAINT fkpost_id FOREIGN KEY (post_id) REFERENCES posts(id)
    
);

CREATE INDEX on posts (id, dt, mentions DESC);

CREATE INDEX on comments (id, dt, post_id DESC);

SELECT create_hypertable('posts','dt');

SELECT create_hypertable('comments','dt');
