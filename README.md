# Netflix Movies and TV Shows Data Analysis using SQL
## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

  ## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```
## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix
```sql
select TOP 5 
    country ,
	count(*)
from(
SELECT 
    show_id, 
    type, 
    LTRIM(RTRIM(value)) AS country
FROM 
    netflix
    CROSS APPLY STRING_SPLIT(country, ',')
	) as t2
group by country
ORDER BY 2 DESC
;
```
**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years
```sql
SELECT * 
FROM netflix
WHERE CONVERT(DATE, date_added, 107) >= DATEADD(YEAR, -5, GETDATE())
```
**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM netflix
WHERE type='TV Show' and duration >= '5%';
```
**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre
```SQL
SELECT  genre, count(*) AS no_released
from(
SELECT 
    show_id, 
    type, 
    LTRIM(RTRIM(value)) AS genre
FROM 
    netflix
    CROSS APPLY STRING_SPLIT(listed_in, ',')
	) as t3
	GROUP BY genre
	ORDER BY no_released DESC
```
**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
```SQL
SELECT TOP 5
	DATEPART(YEAR,date_added) AS YEAR,
	COUNT(*) AS yearly_content,
	ROUND(CAST(COUNT(*) AS FLOAT)*100/(SELECT COUNT(*) FROM NETFLIX WHERE COUNTRY LIKE '%INDIA%'),2) AS average_content
FROM netflix 
WHERE country LIKE '%INDIA%' 
GROUP BY  DATEPART(YEAR,date_added)
ORDER BY COUNT(*) DESC
```
**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
SELECT *
FROM netflix 
WHERE type= 'Movie' 
AND
cast LIKE '%Salman Khan%' 
AND
CONVERT(DATE, date_added, 107) >= DATEADD(YEAR, -10, GETDATE())
```
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT TOP 10
    actor,
	COUNT(*) AS appearance
FROM
(
SELECT 
LTRIM(RTRIM(value)) AS actor
FROM netflix
CROSS APPLY STRING_SPLIT(cast,',')
WHERE country LIKE '%INDIA%'
) as t4
GROUP BY actor
ORDER BY 2 desc
'''
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
WITH new_table 
AS
(
SELECT *,
CASE 
    WHEN
	     description LIKE '%KILL%'
	     OR
	     description LIKE '%VIOLENCE%' 	THEN 'BAD_CONTENT'
         ELSE 'GOOD_CONTENT'
	END category
FROM netflix
)
SELECT category , COUNT(*) AS total_content
FROM new_table
GROUP BY category
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.


	
