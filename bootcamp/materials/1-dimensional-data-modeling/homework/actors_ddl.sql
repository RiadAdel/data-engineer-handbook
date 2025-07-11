CREATE TYPE film AS (
	filmid text, film text, votes bigint, rating REAL
)

CREATE TYPE quality_class AS ENUM('star', 'good', 'average', 'bad')

CREATE TABLE actors (
	actorid text, actor text, films film[], quality_class quality_class, is_active BOOLEAN, current_year int, PRIMARY KEY (actorid, current_year)
)
