DROP SCHEMA IF EXISTS lab82 CASCADE;

CREATE SCHEMA lab82;
SET search_path = lab82;

CREATE EXTENSION pg_trgm;

CREATE TABLE p1 (
    body text,
    body_indexed text
);

INSERT INTO p1
	SELECT
    	md5(random()::text)
	FROM (
		SELECT * FROM
			generate_series (1,100000) AS id
		) AS x;

UPDATE p1 SET body_indexed = body;

CREATE INDEX p1_search_idx ON p1 USING gin (body_indexed gin_trgm_ops);

SELECT COUNT(*) FROM p1 WHERE body LIKE '%abc%';
SELECT COUNT(*) FROM p1 WHERE body_indexed LIKE '%abc%';