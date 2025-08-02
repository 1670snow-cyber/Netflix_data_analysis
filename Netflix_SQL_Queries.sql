-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY type ;

-- 2. Find the most common rating for movies and TV shows
WITH rating_counts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS nums
    FROM netflix
    GROUP BY type, rating
)
SELECT 
    type,
    rating
FROM (
    SELECT 
        type,
        rating,
        nums,
        RANK() OVER (PARTITION BY type ORDER BY nums DESC) AS ranking
    FROM rating_counts
) AS t1
WHERE ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020

--Q4  Find the top 5 countries with the most content on Netflix

select TOP 5 
    country ,
	count(*) num_movies
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
-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
AND 
duration =(SELECT MAX(duration) FROM netflix)


-- 6. Find content added in the last 5 years

SELECT * 
FROM netflix
WHERE CONVERT(DATE, date_added, 107) >= DATEADD(YEAR, -5, GETDATE())

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'



-- 8. List all TV shows with more than 5 seasons

select * from netflix where type='TV Show' and duration >= '5%'

--Q9 Count the number of content items in each genre
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

--q10  Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT TOP 5
	DATEPART(YEAR,date_added) AS YEAR,
	COUNT(*) AS yearly_content,
	ROUND(CAST(COUNT(*) AS FLOAT)*100/(SELECT COUNT(*) FROM NETFLIX WHERE COUNTRY LIKE '%INDIA%'),2) AS average_content
FROM netflix 
WHERE country LIKE '%INDIA%' 
GROUP BY  DATEPART(YEAR,date_added)
ORDER BY COUNT(*) DESC

--Q11 List all movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries%'
AND type='Movie'

--q12 Find all content without a director
SELECT * FROM netflix WHERE director IS NULL

--Q13  Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix 
WHERE type= 'Movie' 
AND
cast LIKE '%Salman Khan%' 
AND
CONVERT(DATE, date_added, 107) >= DATEADD(YEAR, -10, GETDATE())

--Q14 Find the top 10 actors who have appeared in the highest number of movies produced in India.
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
ORDER BY 2 desc;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

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
GROUP BY category;
	
