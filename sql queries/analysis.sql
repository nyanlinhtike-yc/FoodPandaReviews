USE FoodPandaReviews;
GO

-- Total stores on foodpanda for delivery.
SELECT COUNT(*) AS total_stores FROM foodpanda_reviews.stores;

-- List all the unique cities where FoodPanda operates.
SELECT DISTINCT city FROM foodpanda_reviews.stores ORDER BY city;

-- Total reviews on foodpanda platform.
SELECT COUNT(*) AS total_reviews FROM foodpanda_reviews.reviews;

-- Stores that used foodpanda per province.
SELECT 
	city,
	COUNT(*) AS total_stores
FROM foodpanda_reviews.stores
GROUP BY city
ORDER BY total_stores DESC;

-- Store avg Rating per province.
SELECT
	city,
	CONVERT(DECIMAL(3,2), ROUND(AVG(avg_rating),2 )) AS avg_rating
FROM foodpanda_reviews.stores
GROUP BY city
ORDER BY avg_rating DESC;

-- Most TOP 20 reviewers stores.
SELECT TOP 20
	store_name,
	SUM(reviewers) AS total_reviewers
FROM foodpanda_reviews.stores
GROUP BY store_name
ORDER BY total_reviewers DESC, store_name;

-- Most reviewed stores on each city.
WITH row_cte AS (
	SELECT 
		city,
		store_name,
		COUNT(*) AS total_reviews,
		ROW_NUMBER() OVER (PARTITION BY city ORDER BY COUNT(*) DESC) AS row_num
	FROM foodpanda_reviews.reviews r
	JOIN foodpanda_reviews.stores s
		ON r.store_id = s.store_id
	GROUP BY 
		city, 
		store_name
)
SELECT
	city,
	store_name,
	total_reviews
FROM row_cte
WHERE row_num = 1
ORDER BY total_reviews DESC;

select food_type,	PERCENTILE_CONT(0.75) within group (order by sum(reviewers)) over() from foodpanda_reviews.stores group by food_type

-- Avg rating and reviewers for all cities on each foot type and total reviewers must be greater than 1000.
SELECT
	food_type,
	CONVERT(DECIMAL(3,2), ROUND(AVG(avg_rating), 2)) AS avg_rating,
	SUM(reviewers) AS total_reviewers
FROM foodpanda_reviews.stores
GROUP BY food_type
HAVING SUM(reviewers) > 1000
ORDER BY avg_rating DESC, total_reviewers DESC;

-- Most tourist visited provinces according to the web sources.
-- Avg rating and reviewer count on each food type might be influence by a factor of tourist area.
SELECT
	food_type,
	CONVERT(DECIMAL(3,2), ROUND(AVG(avg_rating), 2)) AS avg_rating,
	SUM(reviewers) AS total_reviewers
FROM foodpanda_reviews.stores
WHERE city IN ('Bangkok', 'Chiang Mai', 'Chon Buri', 'Kanchanaburi', 'Chiang Rai')
GROUP BY food_type
HAVING SUM(reviewers) > 1000
ORDER BY avg_rating DESC, total_reviewers DESC;

-- Is there any store rating trends based on monthly?
SELECT
	YEAR(created_at) AS year,
	MONTH(created_at) AS month,
	AVG(overall) AS avg_overall_ratings
FROM foodpanda_reviews.reviews
GROUP BY 
	YEAR(created_at),
	MONTH(created_at)
ORDER BY year, month;

-- Rating distribution.
SELECT overall,
	COUNT(*) AS total_count
FROM foodpanda_reviews.reviews
GROUP BY overall
ORDER BY total_count DESC;

-- Positive reviews percentage by city and store.
SELECT 
	city,
	store_name, 
	COUNT(*) AS total_count,	
    AVG(overall) AS avg_rating,
    SUM(CASE WHEN overall >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS positive_reviews_percentage
FROM foodpanda_reviews.reviews r
JOIN foodpanda_reviews.stores s
	ON s.store_id = r.store_id
GROUP BY city, store_name
HAVING COUNT(*) > 50
ORDER BY positive_reviews_percentage DESC, total_count DESC;

-- Positive rating and negative rating on each store and city.
SELECT 
	store_name, 
	city, 
	COUNT(*) AS total_count,
	SUM(CASE WHEN overall >= 4 THEN 1 END) AS positive_rating,
		SUM(CASE WHEN overall <= 2 THEN 1 END) as negative_rating
FROM foodpanda_reviews.reviews r
JOIN foodpanda_reviews.stores s
	ON s.store_id = r.store_id
GROUP BY store_name, city
ORDER BY total_count DESC, negative_rating DESC, positive_rating DESC

-- Rider rating distribution.
SELECT 
	COALESCE(CONVERT(VARCHAR(MAX), rider), 'Unkown') AS rider_rating,
	COUNT(*) AS total_count,
	AVG(overall) AS avg_rating
FROM foodpanda_reviews.reviews
GROUP BY CONVERT(VARCHAR(MAX), rider)
ORDER BY total_count DESC;

-- Relationship between review length and overall rating.
SELECT 
	store_name,
	LEN(review_text) AS review_length,
	overall AS overall_rating
FROM foodpanda_reviews.reviews r
JOIN foodpanda_reviews.stores s
	ON s.store_id = r.store_id
ORDER BY review_length DESC;

-- Language count on review texts.
SELECT	
	language_name,
	COUNT(*) AS total_count
FROM foodpanda_reviews.reviews r
JOIN foodpanda_reviews.language_codes l
	ON r.lang = l.iso_code
GROUP BY language_name
ORDER BY total_count DESC;

SELECT * FROM foodpanda_reviews.reviews;
SELECT * FROM foodpanda_reviews.stores 