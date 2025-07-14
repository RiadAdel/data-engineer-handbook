INSERT INTO actors 
WITH yesterday AS(
	SELECT * FROM actors
	WHERE current_year = 2003
), today AS (
SELECT *
FROM actor_films a
WHERE YEAR = 2004
)
SELECT COALESCE(t.actorid, y.actorid) AS actorid, COALESCE(t.actor, y.actor) AS actor, CASE WHEN max(y.films) IS NULL THEN 
array_agg( ROW(t.filmid , t.film , t.votes , t.rating )::film)
WHEN array_agg( ROW(t.filmid , t.film , t.votes , t.rating )::film) IS NULL
THEN max(y.films)
ELSE
max(y.films) || array_agg( ROW(t.filmid , t.film , t.votes , t.rating )::film)
END films, COALESCE(CASE
	WHEN avg(t.rating) > 8
	THEN 'star'::quality_class
WHEN avg(t.rating) > 7
	THEN 'good'::quality_class
WHEN avg(t.rating) > 6
	THEN 'average'::quality_class
WHEN avg(t.rating) <= 6
	THEN 'bad'
END, max(y.quality_class)) AS quality_class, max(t.actorid) IS NOT NULL AS is_active, COALESCE(t.YEAR, y.current_year + 1) AS current_year
FROM today t
FULL OUTER JOIN yesterday y ON
t.actorid = y.actorid
GROUP BY COALESCE(t.actorid, y.actorid), COALESCE(t.actor, y.actor), COALESCE(t.YEAR, y.current_year + 1)