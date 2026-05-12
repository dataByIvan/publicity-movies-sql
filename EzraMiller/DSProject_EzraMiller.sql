USE sem_project;

-- Matthew Bustos
-- Case Analysis of Ezra Miller
 
/* needed to utilize pandas on vs code in order to format the .csv file in UTF-8. When first downloading the .csv file it was in ASCII, so 
Data IMport Wizard was not funcitioning */

SELECT 
    COUNT(*) - COUNT(score) AS missing_score,
    COUNT(*) - COUNT(revenue) AS missing_revenue,
    COUNT(*) - COUNT(date_x) AS missing_date
FROM imdb_movies_raw;
-- testing for any null/ missing values--> query returned 0 across al three sections

-- Basic Summary Stats
SELECT 
    AVG(score) AS avg_score,
    MIN(score) AS min_score,
    MAX(score) AS max_score,
    AVG(revenue) AS avg_revenue,
    MAX(revenue) AS max_revenue
FROM imdb_movies_raw;

SELECT *
FROM imdb_movies_raw LIMIT 1000000;
-- 10178 rows returned

SELECT *
FROM imdb_movies_raw
WHERE crew LIKE "%Ezra Miller%"; 
-- 10 movies returned

SELECT crew, date_x, score, revenue
FROM imdb_movies_raw
WHERE crew LIKE '%Ezra Miller%'
ORDER BY date_x;
-- tried ordering by date, looks like the date_x is in string format. going to add a fixed date column
ALTER TABLE imdb_movies_raw
ADD COLUMN date_fixed DATE;
UPDATE imdb_movies_raw
SET date_fixed = STR_TO_DATE(TRIM(date_x), '%m/%d/%Y');
-- Now should run
SELECT names, crew, date_fixed, score, revenue
FROM imdb_movies_raw
WHERE crew LIKE '%Ezra Miller%'
ORDER BY date_fixed;

-- Create a table for just the Movies containing Ezra Miller
CREATE TABLE ezra AS
SELECT
    names,
    orig_title,
    STR_TO_DATE(TRIM(date_x), '%m/%d/%Y') AS release_date,
    CONVERT(NULLIF(score, ''), DECIMAL(3,1)) AS score_num,
    CONVERT(NULLIF(revenue, ''), UNSIGNED) AS revenue_num,
    CONVERT(NULLIF(budget_x, ''), UNSIGNED) AS budget_num,
    genre,
    overview,
    crew,
    status,
    orig_lang,
    country
/* While working with the dataset, I saw that several numeric fields such as score, revenue, and budget were stored as text. 
This caused issues when trying to sort or compute averages. To address this, I researched ways to convert text into numeric types in SQL 
and learned about the CONVERT() function. I also learned about the unsigned since I was working with money sums, and would pnly be searching for numbers
0 and up */

FROM imdb_movies_raw
WHERE crew LIKE '%Ezra Miller%';

DESCRIBE ezra;
SELECT * 
FROM ezra
ORDER BY release_date DESC;
-- Imported google trends search with the key word 'ezra miller'

DESCRIBE search_trends;
SELECT * 
FROM search_trends LIMIT 100;

-- Summary Stats
SELECT 
    AVG(subject) AS avg_interest,
    MIN(subject) AS min_interest,
    MAX(subject) AS max_interest
FROM search_trends;

-- Avg interest from 2020-2026: 8.91
-- Min Interest (searches): 2
-- Max Interest (searches): 100

SELECT *
FROM search_trends
ORDER BY subject DESC;

/* Ezra miller's name hit the peak popularity on June 1st, 2022. Here is details from Google explaining the number system:
"100: Represents the peak popularity for the term in that specific time period and region. 50: Means the term is half as popular as the peak."
June 2022 is around the time ezra was charged for grooming as well as second degree assault. */

-- Comparing revenue from movies with Miller's name in it before and after this June 1 date

SELECT
    'before controversy' AS period,
    COUNT(*) AS num_movies,
    AVG(revenue_num) AS avg_revenue,
    SUM(revenue_num) AS total_revenue
FROM ezra
WHERE revenue_num IS NOT NULL
AND release_date < '2022-06-01'
UNION ALL
SELECT
    'after controversy' AS period,
    COUNT(*) AS num_movies,
    AVG(revenue_num) AS avg_revenue,
    SUM(revenue_num) AS total_revenue
FROM ezra
WHERE revenue_num IS NOT NULL
AND release_date >= '2022-06-01';

SELECT *
FROM ezra;
 
-- Before 06/01/2022: 9 movies with a total revenue of 2226274247 made across the 9 movies
-- After 06/01/2022: 1 movie total revenue of 1240262
-- Important to note that movies can be under various franchises/small indie companies -- this will largely affect box office turnout.
-- Obvious detail is that since the controversial period Miller has not received many big time roles

-- No joins yet, I think I would need to obtain one more dataset that filters through news stories, and be able to join it across the two existing tables explored

-- Trying to find movies that were released after  peak in google search popularity, AND are above the average revenue
SELECT orig_title, revenue_num
FROM ezra
WHERE release_date >= '2022-06-01'
AND revenue_num > (
    SELECT AVG(revenue_num)
    FROM ezra
    WHERE revenue_num IS NOT NULL
);

-- Nothing found. Maybe the average revenue of movies he's involved in is already low. Tried setting the date to 2019-06-01 and found only one movie: Fantastic Beasts: The Secrets of Dumbledore
-- to observe the big effects of Miller's controversial period, I will import a google serach trends csv that dates to the time before his first major movie (2011).

/* Testing to find movies with newly imported revenues_per_day table. This table was found thanks for github user tjwaterman99, who explains that this
is a "daily export of box office revenues scraped from Box Office Mojo. Each daily export contains all revenue data from January 1st, 2000 up to the current day."
link provided here: https://github.com/tjwaterman99/boxofficemojo-scraper
I imported this table because i believe looking at week-byweek revenue and potential increases/decreases in theaters that show the movie can paint a bigger picture
of the effect of ezra miller's periods of controversy. */

-- checking which Ezra movies match the revenue table to find any missing data
SELECT 
	e.orig_title,
    COUNT(r.date) AS num_daily_records,
    MIN(r.date) AS first_revenue_date,
    MAX(r.date) AS last_revenue_date
FROM ezra e
LEFT JOIN revenues_per_day r -- need to left join so that it keeps all the titles ezra miller was in as recorded in the ezra table
    ON e.orig_title = r.title
GROUP BY e.orig_title
ORDER BY COUNT(r.date) DESC;
-- Four movies did not record any data for unknown reasons: "We Need to Talk About Kevin", "Asking For It", "Zack Snyder's Justice League", and "The Stanford Prison Experiment"
-- I will shift focus to just the titles that recorded revenue data. Ill create a separate table with just the recorded movies, joining witht he data from the ezra table.

CREATE TABLE ezra_daily_revenue AS
SELECT
    e.orig_title,
    e.release_date,
    e.score_num,
    e.revenue_num AS total_revenue,
    e.budget_num,
    r.date AS revenue_date,
    r.revenue AS daily_revenue,
    r.theaters,
    r.distributor,
    DATEDIFF(r.date, e.release_date) AS days_since_release,
    FLOOR(DATEDIFF(r.date, e.release_date) / 7) + 1 AS release_week -- used floor and + 1 since datediff counts the opening day as 0 --> round down then + 1 so that it is classified under Week 1
FROM ezra e
JOIN revenues_per_day r
    ON e.orig_title = r.title
WHERE r.date >= e.release_date
AND e.orig_title IN (
    'The Perks of Being a Wallflower',
    'Justice League',
    'Fantastic Beasts: The Crimes of Grindelwald',
    'Trainwreck',
    'Fantastic Beasts: The Secrets of Dumbledore',
    'The Flash'
);

SELECT *
FROM 
ezra_daily_revenue
ORDER BY orig_title, release_week DESC;

SELECT
    orig_title,
    release_week,
    SUM(daily_revenue) AS weekly_revenue,
    AVG(theaters) AS avg_theaters
FROM ezra_daily_revenue
WHERE release_week BETWEEN 1 AND 8 -- baseline for hit blockbuster movies is around 4-8 per google
GROUP BY orig_title, release_week 
ORDER BY orig_title, release_week;

-- running a query to observe the retention rate of miller's movies. this essentially will help me draw closer to the answer of whether his controversies significatnyl affected the film's theatrical run
-- thought it woul dbe best to compare opening week vs week 4 as week 4 is in the middle of the 1-8 period that i had generated in the previous query
WITH weekly AS (
    SELECT
        orig_title,
        release_week,
        SUM(daily_revenue) AS weekly_revenue,
        ROUND(AVG(theaters), 0) AS avg_theaters
    FROM ezra_daily_revenue
    WHERE release_week IN (1, 4)
    GROUP BY orig_title, release_week
)
SELECT
    w1.orig_title,
    w1.weekly_revenue AS week_1_revenue,
    w4.weekly_revenue AS week_4_revenue,
    ROUND(w4.weekly_revenue / w1.weekly_revenue * 100, 2) AS w4_revenue_percent,
    w1.avg_theaters AS week_1_avg_theaters,
    w4.avg_theaters AS week_4_avg_theaters,
    ROUND(w4.avg_theaters / w1.avg_theaters * 100, 2) AS w4_theater_retention
FROM weekly w1
JOIN weekly w4
    ON w1.orig_title = w4.orig_title
WHERE w1.release_week = 1
AND w4.release_week = 4
ORDER BY w4_revenue_percent DESC;
-- Findings from Week 1 vs Week 4 Retention Analysis

-- "The Perks of Being a Wallflower" (pre controvery movie) showed the strongest revenue retention (46.8%), suggesting smaller-scale films may maintain audience engagement longer through word-of-mouth.
-- "The Flash" experienced the sharpest revenue decline, retaining only 4.3% of its Week 1 revenue by Week 4 despite having the highest initial theater count.
-- "Justice League" maintained very high theater retention (87.7%), meaning theaters continued showing the film even while revenue declined significantly.
-- "Fantastic Beasts: The Crimes of Grindelwald" retained only 14.3% of its Week 1 revenue by Week 4, suggesting rapid audience dropoff.
-- "Trainwreck" demonstrated moderate performance sustainability, retaining 23.6% of Week 1 revenue and 47.8% of theater presence.

-- Across most Ezra Miller films, theater retention remained higher than revenue retention, liekly meaning that theaters kept movies in circulation longer than audience demand.
-- creating new updated search trend table
CREATE TABLE ezra_search_trends AS
SELECT
    STR_TO_DATE(Time, '%Y-%m-%d') AS trend_date,
    `ezra miller` AS search_interest
FROM time_series_updated;
-- Search interest by controversy period
SELECT
    CASE
        WHEN trend_date < '2022-06-01' THEN 'pre-controversy'
        WHEN trend_date BETWEEN '2022-06-01' AND '2023-01-01' THEN 'controversy spike'
        ELSE 'post-controversy'
    END AS period,
    AVG(search_interest) AS avg_search_interest,
    MAX(search_interest) AS peak_search_interest,
    MIN(search_interest) AS min_search_interest
FROM ezra_search_trends
GROUP BY period;

-- pre controvery - avg search interest: 2.70, peak search interest: 66, min search interest: 0
-- controvery spike - avg search interest: 28.38, peak search interest: 100, min search interest: 5
-- post controvery - avg search interest: 5.6, peak search interest: 38, min search interest: 2

describe ezra_search_trends;
describe ezra;

WITH monthly_search AS ( -- groups monthly search interest of ezra miller over time
    SELECT
        DATE_FORMAT(trend_date, '%Y-%m-01') AS month_start,
        AVG(search_interest) AS avg_search_interest
    FROM ezra_search_trends
    GROUP BY month_start
), monthly_revenue AS ( -- groups monthly revenue of miller's movies by formatting each weekly date to the first of each month, then converting to date type
    SELECT
        STR_TO_DATE(DATE_FORMAT(revenue_date, '%Y-%m-01'), '%Y-%m-%d') AS month_start,
        SUM(daily_revenue) AS total_monthly_revenue
    FROM ezra_daily_revenue
    GROUP BY month_start
), monthly_releases AS (
	SELECT
        DATE_FORMAT(release_date, '%Y-%m-01') AS month_start,
        COUNT(*) AS movies_released
    FROM ezra
    GROUP BY month_start
), combined AS (-- I joined the monthly search table with monthly revenue and monthly releasesso all three metrics could be compared on the same monthly timeline and can be plotted on one graph
    SELECT
        s.month_start,
        s.avg_search_interest,
        COALESCE(r.total_monthly_revenue, 0) AS total_monthly_revenue, -- replaces periods where movies werent released/not making money with 0
        COALESCE(m.movies_released, 0) AS movies_released
    FROM monthly_search s
    LEFT JOIN monthly_revenue r
        ON s.month_start = r.month_start
    LEFT JOIN monthly_releases m
        ON s.month_start = m.month_start
)
SELECT
    month_start,
    avg_search_interest,
    total_monthly_revenue,
    movies_released,
    ROUND(avg_search_interest / MAX(avg_search_interest) OVER () * 100, 2) AS search_index, -- normalized everything to a 0-100 index so that the graph does not look too lopsided with the copious amount of revenue.
    ROUND(total_monthly_revenue / MAX(total_monthly_revenue) OVER () * 100, 2) AS revenue_index, 
    ROUND(movies_released / MAX(movies_released) OVER () * 100, 2) AS movie_frequency_index
FROM combined
ORDER BY month_start;
/* rather than just plotting the three subqueries separately, i combined them all into a multi line plot, scaled to a 0-100 index. I chose to do this because I think observing the spikes and dips 
in ezra's search history along with the frequency of movies he was in can reveal whether the controversial period affected his ability to land more roles.
