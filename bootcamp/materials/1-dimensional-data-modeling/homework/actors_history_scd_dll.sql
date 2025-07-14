CREATE TABLE actors_history_scd (
	actorid TEXT,
	actor TEXT,
	quality_class quality_class,
	is_active boolean,
	start_date int,
	end_date int,
	current_year int,
	PRIMARY KEY (actorid,start_date)
)