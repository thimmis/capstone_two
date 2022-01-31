
--This query gives the number of posts per month that reference GME
WITH posters AS (
SELECT
	TO_CHAR(dt, 'YYYY-MM') AS y_m,
	COUNT(id) as num_posts
FROM posts
WHERE mentions like '%GME%'
GROUP BY 1
)

SELECT
	ps.y_m,
	ps.num_posts

FROM posters 

--This Query give the number of comments for each post
--that references GME
WITH commenters AS (
	SELECT 
		post_id AS pid,
		COUNT(post_id) AS num_coms
	FROM comments
GROUP BY pid),
posts_oi AS (
	SELECT
		id,
		dt
	FROM posts
	WHERE mentions LIKE '%GME%'
)

SELECT
	p.id AS id,
	p.dt AS date,
	com.num_coms

FROM posts_oi AS p
LEFT JOIN commenters AS com
	ON p.id = com.pid;
--Optional:
--WHERE num_coms IS NOT NULL;
--use this to ignore posts with no comments.


