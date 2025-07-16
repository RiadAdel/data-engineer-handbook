CREATE TABLE hosts_cumulated (
	host text,
	month_start date,
	host_activity_datelist date[],
	PRIMARY KEY (host,month_start)
);

INSERT INTO hosts_cumulated
WITH yesterday AS (
	SELECT *
	FROM hosts_cumulated
	WHERE month_start = '2023-01-01'
), today AS (
SELECT e.host,date(e.event_time) AS event_date 
FROM events e
WHERE date(e.event_time) = '2023-01-07	'
GROUP BY e.host, date(e.event_time) 
)
SELECT coalesce(y.host,t.host) AS host,
date_trunc('month', COALESCE(y.month_start,t.event_date))::date AS month_start,
CASE 
	WHEN y.host_activity_datelist IS NULL THEN ARRAY[date(t.event_date)]
	WHEN t.host IS NULL THEN y.host_activity_datelist
	ELSE date(t.event_date) || y.host_activity_datelist
END AS host_activity_datelist
FROM today t
FULL OUTER JOIN yesterday y ON t.host = y.host
ON CONFLICT (host, month_start)
DO
    UPDATE SET host_activity_datelist = EXCLUDED.host_activity_datelist;