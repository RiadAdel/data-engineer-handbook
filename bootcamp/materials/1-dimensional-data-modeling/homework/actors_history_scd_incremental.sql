CREATE TYPE actor_scd AS  (
	actorid text,
	actor text,
	quality_class quality_class,
	is_active boolean,
	start_date int,
	end_date int,
	current_year int
);
WITH historical_scd AS (
	SELECT *
FROM actors_history_scd a
WHERE a.current_year = 2003
AND a.end_date < 2003
), new_actors AS (
	SELECT *
FROM actors a
WHERE a.current_year = 2004
), current_actors AS (
	SELECT *
FROM actors_history_scd a
WHERE a.current_year = 2003
AND a.end_date = 2003
), unchanged_actors AS (
SELECT ca.actorid, ca.actor, ca.quality_class, ca.is_active, ca.start_date, na.current_year AS end_date, na.current_year AS current_year
FROM new_actors na
JOIN current_actors ca ON
na.actorid = ca.actorid
), recent_actors AS (
SELECT na.actorid, na.actor, na.quality_class, na.is_active, na.current_year AS start_date, na.current_year AS end_date, na.current_year AS current_year
FROM new_actors na
LEFT JOIN current_actors ca ON
na.actorid = ca.actorid
WHERE ca.actorid IS NULL
), changed_actors AS (
SELECT unnest(ARRAY[
		ROW(ca.actorid, ca.actor, ca.quality_class, ca.is_active, ca.start_date, ca.end_date, na.current_year)::actor_scd,
		ROW(na.actorid, na.actor, na.quality_class, na.is_active, na.current_year, na.current_year, na.current_year)::actor_scd
	]) AS records
FROM new_actors na
JOIN current_actors ca ON
na.actorid = ca.actorid
WHERE na."quality_class" <> ca."quality_class"
OR na.is_active <> ca.is_active
)
SELECT (ca.records).*
FROM changed_actors ca
UNION ALL
SELECT *
FROM unchanged_actors
UNION ALL
SELECT *
FROM recent_actors
UNION ALL
SELECT *
FROM historical_scd;

