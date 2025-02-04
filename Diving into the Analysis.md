# Diving into the Analysis

Before diving into the analysis, let's explore the data.

## 1. Data Exploration 🔎

1.1 How many stores use FoodPanda for delivery?

```SQL
SELECT COUNT(*) AS total_stores 
FROM foodpanda_reviews.stores;
```

<img alt="1.1" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/1.1.png">

1.2 How many reviews are there on FoodPanda Platform?

```SQL
SELECT COUNT(*) AS total_reviews 
FROM foodpanda_reviews.reviews;
```

<img alt="1.2" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/1.2.png">

1.3 List all the unique cities where FoodPanda operates.

```SQL
SELECT DISTINCT city 
FROM foodpanda_reviews.stores ORDER BY city;
```

<img alt="1.3" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/1.3.png">

---

## 2. Analysing the Data 🕵️‍♂️

2.1 Number of stores using FoodPanda in each province

```SQL
SELECT 
	city,
	COUNT(*) AS total_stores
FROM foodpanda_reviews.stores
GROUP BY city
ORDER BY total_stores DESC;
```

<img alt="2.1" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/2.1.png">

2.2 This query calculates the average store rating for each province, based on the average rating per store instead of individual reviews.

```SQL
SELECT
	city,
	CONVERT(DECIMAL(3,2), ROUND(AVG(avg_rating),2 )) AS avg_rating
FROM foodpanda_reviews.stores
GROUP BY city
ORDER BY avg_rating DESC;
```

<img alt="2.2" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/2.2.png">

2.3 Top 20 stores with the most reviewers.
> "*We also want to find out which stores have the most reviewers in each province.*"

```SQL
SELECT TOP 20
	store_name,
	SUM(reviewers) AS total_reviewers
FROM foodpanda_reviews.stores
GROUP BY store_name
ORDER BY total_reviewers DESC, store_name;
```

<img alt="2.3" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/2.3.png">

2.4 Stores that have the most reviewers in each province.

```SQL
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
```

<img alt="2.4" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/2.4.png">

2.5 We calculates the average rating and total number of reviewers for each food type where the total number of reviewers exceeds **1,000**, ensuring a more **reliable** dataset for comparison.

```SQL
SELECT
	food_type,
	CONVERT(DECIMAL(3,2), ROUND(AVG(avg_rating), 2)) AS avg_rating,
	SUM(reviewers) AS total_reviewers
FROM foodpanda_reviews.stores
GROUP BY food_type
HAVING SUM(reviewers) > 1000
ORDER BY avg_rating DESC, total_reviewers DESC;
```

*we only show the partial result.*

<img alt="2.5" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/2.5.png">

> "*As Thailand is a popular tourist destination, we are curious about how the most tourist visited provinces influence ratings and food types.*"

2.6 Average rating and total number of reviewers on each foot type based on most visited area. The provinces are chosen according to web sources.

```SQL
SELECT
	food_type,
	AVG(avg_rating) AS avg_rating,
	SUM(reviewers) AS total_reviewers
FROM foodpanda_reviews.stores
WHERE city IN ('Bangkok', 'Chiang Mai', 'Chon Buri', 'Kanchanaburi', 'Chiang Rai')
GROUP BY food_type
HAVING SUM(reviewers) > 1000
ORDER BY avg_rating DESC, total_reviewers DESC;
```

*we only show the partial result.*

<img alt="2.6" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/2.6.png">

2.7 Is there any overall rating trends based on monthly review ratings.

```SQL
SELECT
	YEAR(created_at) AS year,
	MONTH(created_at) AS month,
	AVG(overall) AS avg_overall_ratings
FROM foodpanda_reviews.reviews
GROUP BY 
	YEAR(created_at),
	MONTH(created_at)
ORDER BY year, month;
```

*The results seem unusual, but the actual data might be different.*

<img alt="2.7" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/2.7.png">

2.8 Rating Distribution for all stores.

```SQL
SELECT overall,
	COUNT(*) AS total_count
FROM foodpanda_reviews.reviews
GROUP BY overall
ORDER BY total_count DESC;
```

<img alt="2.8" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/2.8.png">

---

## 3. Deep Analysis 🔬

>"*We’ve observed the rating distribution, and now we’ll dive deeper into understanding the ratio of positive to negative ratings for the most reviewed stores.*"

3.1 Positive rating and negative rating on each store and city.

```SQL
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
```
*we only show the partial result.*

<img alt="3.1" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/3.1.png">

We are using visual plot to have better understand on how positive and negative ratio on each store.

<img alt="3.1.1" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/3.1.1.png">

3.2 Relationship between overall ratings and rider rating

> "*Looks like higher rider ratings tend to correlate with higher overall ratings.*"

```SQL
SELECT 
	COALESCE(CONVERT(VARCHAR(MAX), rider), 'Unkown') AS rider_rating,
	COUNT(*) AS total_count,
	AVG(overall) AS avg_rating
FROM foodpanda_reviews.reviews
GROUP BY CONVERT(VARCHAR(MAX), rider)
ORDER BY total_count DESC;
```

<img alt="3.2" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/3.2.png">

Here is the scatter plot on rider ratings and overall ratings.

<img alt="3.2.1" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/3.2.1.png">

3.3 Relationship between review length and overall rating.

```SQL
SELECT 
	store_name,
	LEN(review_text) AS review_length,
	overall AS overall_rating
FROM foodpanda_reviews.reviews r
JOIN foodpanda_reviews.stores s
	ON s.store_id = r.store_id
ORDER BY review_length DESC;
```

*we only show the partial result.*

<img alt="3.3" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/3.3.png">

Here is the scatter plot on review length and overall rating.

*Actual data might be different.*

<img alt="3.3.1" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/3.3.1.png">

---

> "*It's useful to know which languages reviewers used, but the results contain some errors when detecting single words or short sentences.*"

```SQL
SELECT	
	language_name,
	COUNT(*) AS total_count
FROM foodpanda_reviews.reviews r
JOIN foodpanda_reviews.language_codes l
	ON r.lang = l.iso_code
GROUP BY language_name
ORDER BY total_count DESC;
```

*we only show the partial result.*

<img alt="4.1" src="https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/images/4.1.png">

[Here] we go to the Summary.

[Here]: https://github.com/nyanlinhtike-yc/FoodPandaReviews/blob/main/Key%20Insights%20%26%20Takeaways.md
