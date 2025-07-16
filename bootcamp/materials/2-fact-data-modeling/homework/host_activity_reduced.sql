CREATE TABLE host_activity_reduced (
	host text,
	month_start date,
	hit_array int[],
	unique_visitors int[],
	PRIMARY KEY (host,month_start)
);

INSERT INTO host_activity_reduced
WITH yesterday AS (
	SELECT *
	FROM host_activity_reduced
	WHERE month_start = '2023-01-01'
),
today AS (
	SELECT e.host, date(e.event_time) AS event_date, COALESCE(count(DISTINCT e.user_id),0) AS unique_visitors, COALESCE(count(1),0) AS hits
	FROM events e 
	WHERE date(e.event_time) = '2023-01-09'
	GROUP BY e.host, date(e.event_time)
)
SELECT coalesce(y.host,t.host) AS host,
		date_trunc('month',coalesce(y.month_start,t.event_date))::date AS month_start,
		CASE
			WHEN t.host IS NULL THEN y.hit_array || ARRAY[0]
			WHEN y.hit_array IS NULL THEN array_fill(0, ARRAY[(t.event_date-date_trunc('month',t.event_date)::date )]) || t.hits
			ELSE y.hit_array || t.hits
		END hit_array,
			CASE
			WHEN t.host IS NULL THEN y.unique_visitors || ARRAY[0]
			WHEN y.unique_visitors IS NULL THEN array_fill(0, ARRAY[(t.event_date-date_trunc('month',t.event_date)::date )]) || t.unique_visitors
			ELSE y.unique_visitors || t.unique_visitors
		END unique_visitors
FROM today t
FULL OUTER JOIN yesterday y ON t.host = y.host
ON CONFLICT (host, month_start)
DO
    UPDATE SET unique_visitors = EXCLUDED.unique_visitors,
        hit_array = EXCLUDED.hit_array;

SELECT * FROM host_activity_reduced;