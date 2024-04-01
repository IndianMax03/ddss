DROP TABLE IF EXISTS top_films;

CREATE TEMPORARY TABLE top_films AS
SELECT f.name AS film_name, AVG(r.rating) AS avg_rating
FROM films f
JOIN reviews r ON f.id = r.film_id
GROUP BY f.id, f.name
ORDER BY avg_rating DESC;

DROP TABLE IF EXISTS bad_reviews;
CREATE TEMPORARY TABLE bad_reviews AS
SELECT f.name AS film_name, r.post AS review_comment, r.rating AS review_rating
FROM films f
JOIN reviews r ON f.id = r.film_id
ORDER BY r.rating;
