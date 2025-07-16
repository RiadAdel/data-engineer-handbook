WITH
ranked_game_details AS (
	SELECT *, row_number() OVER(PARTITION BY game_id) AS rank_num
	FROM game_details
),
deduped_game_details AS (
SELECT *
FROM ranked_game_details
WHERE rank_num = 1
)
SELECT *
FROM deduped_game_details;