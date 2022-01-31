
/* 
Below are the two queries I use, one specifically looking for GME the other not.

The first selects a certain number of randomly ordered ids. Then it selects the posts and adds the corresponding comments.

The second does the same but only when GME is mentioned in either the post title or the text body of the post.
*/

--training set below

\copy (
	WITH rand_id AS (
		SELECT id 
		FROM posts 
		TABLESAMPLE BERNOULLI (41.06) REPEATABLE(42)
		WHERE DATE(dt) BETWEEN '2016-01-01' AND '2020-06-01' 
	) 
	(
	SELECT p.id as id, p.dt as dt,'post' as thetype, CONCAT(p.title, ' ', p.body)as body 
	FROM posts as p 
	WHERE p.id in (SELECT id FROM rand_id)) 
	UNION 
	(SELECT c.post_id as id, c.dt as dt, 'comment' as thetype, regexp_replace(c.body,'[\n\r]+', '', 'g') as body 
	FROM comments as c 
	WHERE c.post_id in (SELECT id FROM rand_id)
	)
	ORDER BY id DESC, dt ASC
) to '/home/thomas/Desktop/2016_2020_06_training_bernoulli_160k.csv' CSV HEADER;

\copy (WITH rand_id AS (SELECT id FROM posts TABLESAMPLE BERNOULLI (41.06) REPEATABLE(42) WHERE DATE(dt) BETWEEN '2016-01-01' AND '2020-06-01' ) (SELECT p.id as id, p.dt as dt,'post' as thetype, CONCAT(p.title, ' ', p.body)as body FROM posts as p WHERE p.id in (SELECT id FROM rand_id)) UNION (SELECT c.post_id as id, c.dt as dt, 'comment' as thetype, regexp_replace(c.body,'[\n\r]+', '', 'g') as body FROM comments as c WHERE c.post_id in (SELECT id FROM rand_id)) ORDER BY id DESC, dt ASC) to '/home/thomas/Desktop/2016_2020_06_training_bernoulli_160k.csv' CSV HEADER;

--validation set below

\copy (
	WITH rand_id AS (
		SELECT id 
		FROM posts 
		TABLESAMPLE BERNOULLI (5.525) REPEATABLE(42)
		WHERE DATE(dt) BETWEEN '2020-06-02' AND '2021-02-01' 
	) 
	(
	SELECT p.id as id, p.dt as dt,'post' as thetype, CONCAT(p.title, ' ', p.body)as body 
	FROM posts as p 
	WHERE p.id in (SELECT id FROM rand_id)) 
	UNION 
	(SELECT c.post_id as id, c.dt as dt, 'comment' as thetype, regexp_replace(c.body,'[\n\r]+', '', 'g') as body 
	FROM comments as c 
	WHERE c.post_id in (SELECT id FROM rand_id)
	)
	ORDER BY id DESC, dt ASC
) to '/home/thomas/Desktop/2020_06_2021_02_validation_bernoulli_40k.csv' CSV HEADER;

\copy (WITH rand_id AS (SELECT id FROM posts TABLESAMPLE BERNOULLI (5.525) REPEATABLE(42) WHERE DATE(dt) BETWEEN '2020-06-02' AND '2021-02-01') (SELECT p.id as id, p.dt as dt,'post' as thetype, CONCAT(p.title, ' ', p.body)as body FROM posts as p WHERE p.id in (SELECT id FROM rand_id)) UNION (SELECT c.post_id as id, c.dt as dt, 'comment' as thetype, regexp_replace(c.body,'[\n\r]+', '', 'g') as body FROM comments as c WHERE c.post_id in (SELECT id FROM rand_id)) ORDER BY id DESC, dt ASC) to '/home/thomas/Desktop/2020_06_2021_02_validation_bernoulli_40k.csv' CSV HEADER;






--GME ONLY TEST BELOW


\copy (
	WITH rand_id AS (
		SELECT id 
		FROM posts 
		WHERE (title LIKE '%GME%') OR (body LIKE '%GME%') AND (DATE(dt) < '2021-02-01') 
		ORDER BY RANDOM() LIMIT 100) 
	(SELECT p.id as id, p.dt as dt,'post' as thetype, CONCAT(p.title, ' ', p.body)as body 
	FROM posts as p 
	WHERE p.id in (SELECT id FROM rand_id)) 
	UNION 
	(SELECT c.post_id as id, c.dt as dt, 'comment' as thetype, regexp_replace(c.body,'[\n\r]+', '', 'g') as body 
	FROM comments as c 
	WHERE c.post_id in (SELECT id FROM rand_id))
	ORDER BY id DESC, dt ASC
) to '/home/thomas/Desktop/GME100random.csv' CSV HEADER;


SELECT COUNT(*)
FROM posts
TABLESAMPLE BERNOULLI(5.525) REPEATABLE (42)
WHERE DATE(dt) BETWEEN '2020-06-02' AND '2021-02-01';


