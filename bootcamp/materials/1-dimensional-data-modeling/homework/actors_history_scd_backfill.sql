INSERT INTO actors_history_scd
WITH actors_with_prev AS (
SELECT actorid, actor, quality_class, is_active, current_year, LAG(quality_class) OVER (PARTITION BY actorid
ORDER BY current_year) AS prev_quality_class, LAG(is_active) OVER (PARTITION BY actorid
ORDER BY current_year )AS prev_is_Active
FROM actors
WHERE current_year <= 2003
), actors_with_change_indicators AS (
SELECT 
	*,
	CASE WHEN prev_quality_class <> quality_class THEN 1
	WHEN is_active <> prev_is_active THEN 1
	ELSE 0
	END AS has_changed
FROM actors_with_prev
),
actors_streak AS (
SELECT *, sum(has_changed) OVER (PARTITION BY actorid ORDER BY current_year) AS streak
FROM actors_with_change_indicators 
),
actors_scd AS (
SELECT actorid, streak, actor,quality_class, is_active, min(current_year) AS start_date, max(current_year) AS end_date, 2003 AS current_year
FROM actors_streak
GROUP BY actorid,streak,  actor,quality_class, is_active
)
SELECT actorid, actor, quality_class, is_active, start_date,end_date, current_year
FROM actors_scd
