DROP TABLE user_devices_cumulated ;
CREATE TABLE user_devices_cumulated (
	user_id numeric,
	device_id  numeric,
	browser_type text,
	device_activity_cumulated date[],
	date date,
	PRIMARY KEY (user_id, device_id , date)
);

INSERT INTO user_devices_cumulated 
WITH yesterday AS (
	SELECT *
	FROM user_devices_cumulated
	WHERE date = '2023-01-30'
),
today AS (
	SELECT e.user_id , d.device_id, d.browser_type , DATE(e.event_time) AS date
	FROM devices d
	LEFT JOIN events e ON d.device_id = e.device_id
	WHERE DATE(e.event_time) = '2023-01-31'
	AND e.user_id IS NOT NULL
	AND d.device_id IS NOT NULL
	GROUP BY e.user_id , d.device_id, d.browser_type , DATE(e.event_time)
)
SELECT
	coalesce(y.user_id,t.user_id) AS user_id,
	coalesce(y.device_id,t.device_id) AS device_id,
	coalesce(y.browser_type,t.browser_type) AS browser_type,
	CASE 
		WHEN y.device_activity_cumulated IS NULL THEN ARRAY[t.date]
		WHEN t.date IS NOT NULL THEN t.date || y.device_activity_cumulated 
		ELSE y.device_activity_cumulated
	END AS device_activity_cumulated,
	coalesce(t."date",DATE(y."date" + INTERVAL '1 DAY')) AS date
FROM today t
FULL OUTER JOIN yesterday y ON t.device_id = y.device_id AND t.user_id = y.user_id AND t.browser_type = y.browser_type;

WITH series AS (
	SELECT date(datetime) AS series_date
FROM generate_series('2023-01-01'::date, '2023-01-31'::date, INTERVAL '1 DAY') AS datetime
), device_activity AS (
	SELECT *
FROM user_devices_cumulated u
CROSS JOIN series
WHERE date = '2023-01-31'
), device_activity_with_placeholder AS (
SELECT *, CASE
	WHEN device_activity_cumulated @> ARRAY[series_date::date]  
	THEN CAST( CAST(pow(2, 32-(series_date-date_trunc('month', date)::date + 1)) AS BIGINT) AS BIT(32))
ELSE CAST(0 AS BIT(32)) END placeholder
FROM device_activity
)
SELECT user_id, device_id, browser_type, CAST(CAST (sum(CAST( placeholder AS bigint)) AS BIGINT) AS BIT(32)) datelist_int
FROM device_activity_with_placeholder
GROUP BY user_id, device_id, browser_type;