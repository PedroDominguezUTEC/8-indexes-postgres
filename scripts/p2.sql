-- Create new attribute
ALTER TABLE film ADD COLUMN content_ts tsvector;

-- Fill data
UPDATE film
SET content_ts = x.content_ts FROM (
	SELECT film_id,
			setweight(to_tsvector('english', title), 'A') || 
			setweight(to_tsvector('english', description), 'B') AS content_ts 
	FROM film
	) AS x
WHERE x.film_id = film.film_id;

-- Create index
CREATE INDEX idx_content_ts ON film USING gin(content_ts);

-- Ranked query on indexed attribute
SELECT title, description, ts_rank_cd(content_ts, query_ts) AS score 
FROM film, to_tsquery('english', 'man | woman | monkey') query_ts 
WHERE query_ts @@ content_ts
ORDER BY score DESC; 

-- Ranked query on non-indexed attribute
SELECT title, description, ts_rank_cd(fulltext, query_ts) AS score 
FROM film, to_tsquery('english', 'man | woman | monkey') query_ts 
WHERE query_ts @@ fulltext
ORDER BY score DESC; 

--LIMIT 10;