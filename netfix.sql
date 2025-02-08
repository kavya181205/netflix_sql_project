SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL LOCAL_INFILE= ON;
use kavya;



LOAD DATA LOCAL INFILE 'C:\Users\kavya\OneDrive\Desktop\oot' INTO TABLE netflix_titles_2 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
SHOW VARIABLES LIKE 'local_infile';
LOAD DATA LOCAL INFILE 'C:\\Users\\kavya\\OneDrive\\Desktop\\oot\\netflix_titles.csv'
INTO TABLE netflix_titles_2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select * from netflix_titles_2;
-- 1)How many Movies and TV Shows are available on Netflix?
select type, count(*) as total_content from netflix_titles_2 group by type;
-- 2)Find the most common ratings (PG, TV-MA, etc.) on Netflix.
SELECT type,rating, COUNT(*) AS count
FROM netflix_titles_2
WHERE rating IS NOT NULL
GROUP BY type,rating
ORDER BY count DESC;

-- 3) List all shows that were added to Netflix in 2021.
select type,title from netflix_titles_2 where type='Movie' and release_year=2021;
-- 4)Find all Movies directed by Christopher Nolan (or any famous director in the dataset).
select type,title from netflix_titles_2 where type='Movie' and director='Christopher Nolan';
-- 5)Show all TV Shows with more than 2 seasons.
select type,title,duration from netflix_titles_2 where type='TV Show' and duration>'2 Seasons';





-- 6)How many movies were released each year (from oldest to newest)?
select release_year,count(type) from netflix_titles_2 where type='Movie' group by release_year order by  release_year asc;
 
 --7) Find All Content Without a Director
SELECT * FROM netflix WHERE director="";


alter table netflix_titles_2 rename to netflix;
select * from netflix;

-- 8) Find How Many Movies Actor 'Salman Khan' Appeared in the Last 15 Years
SELECT * 
FROM netflix
WHERE cast LIKE '%Salman Khan%'
            AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 15;

-- 9)List All Movies that are Documentaries  
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 10)Find the first and last content added to Netflix for each country.
SELECT country, title, date_added,
       FIRST_VALUE(title) OVER (PARTITION BY country ORDER BY date_added ASC) AS first_added,
       LAST_VALUE(title) OVER (PARTITION BY country ORDER BY date_added ASC 
                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_added
FROM netflix
WHERE country IS NOT NULL;

-- 11)Identify titles that stayed in the top 5 most added content per year for the longest period.
WITH yearly_ranks AS (
    SELECT title, release_year, 
           RANK() OVER (PARTITION BY release_year ORDER BY COUNT(*) DESC) AS total_titles
    FROM netflix
    GROUP BY release_year, title
)
SELECT title, COUNT(*) AS years_in_top5
FROM yearly_ranks
WHERE total_titles<= 5
GROUP BY title
ORDER BY years_in_top5 DESC;

-- 12)Find how many years passed between each director’s consecutive releases.
SELECT director, title, release_year, 
       LAG(release_year) OVER (PARTITION BY director ORDER BY release_year) AS previous_release,
       release_year - LAG(release_year) OVER (PARTITION BY director ORDER BY release_year) AS gap_years
FROM netflix_titles
WHERE director IS NOT NULL;

-- 13)Show a running total of movies and TV shows added each year.
SELECT release_year, type, COUNT(*) AS yearly_count,
       SUM(COUNT(*)) OVER (PARTITION BY type ORDER BY release_year) AS running_total
FROM netflix
GROUP BY release_year, type;

-- 14)Find the total number of movies and TV shows added each month
SELECT DATE_FORMAT(date_added, '%Y-%m') AS month_added, COUNT(*) AS total_titles
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY month_added
ORDER BY month_added DESC;



