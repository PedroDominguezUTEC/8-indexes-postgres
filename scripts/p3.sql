-- Create table

DROP TABLE IF EXISTS news CASCADE;

CREATE TABLE news(
    num integer,
    id integer,
    title text,
    publication text,
    author text,
    date text, 
    year float,
    month float,
    url text,
    content text
);

ALTER TABLE news ADD COLUMN content_ts tsvector;

-- Fill data
UPDATE news
SET content_ts = x.content_ts FROM (
	SELECT id,
			setweight(to_tsvector('english', title), 'A') || 
			setweight(to_tsvector('english', content), 'B') AS content_ts 
	FROM news
	) AS x
WHERE x.id = news.id;

ALTER TABLE news ADD COLUMN content_ts_no_index tsvector;

UPDATE news
SET content_ts_no_index = x.content_ts FROM (
	SELECT id,
			setweight(to_tsvector('english', title), 'A') || 
			setweight(to_tsvector('english', content), 'B') AS content_ts 
	FROM news
	) AS x
WHERE x.id = news.id;


-- Create index
CREATE INDEX idx_content_ts ON news USING gin(content_ts);

-- Ranked query on indexed attribute
SELECT title, content, ts_rank_cd(content_ts, query_ts) AS score 
FROM news, to_tsquery('english', 'trump | president') query_ts 
WHERE query_ts @@ content_ts
ORDER BY score DESC
limit 100;

-- Ranked query on non-indexed attribute
SELECT title, content, ts_rank_cd(content_ts, query_ts) AS score 
FROM news, to_tsquery('english', 'trump | president') query_ts 
WHERE query_ts @@ content_ts
ORDER BY score DESC
limit 100;