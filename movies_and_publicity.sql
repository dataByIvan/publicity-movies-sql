USE publicity_movies;

-- 1) Dwayne
DESCRIBE dwaynecsv;
-- dwayne csv: https://trends.google.com/explore?q=Dwayne%2520The%2520Ad%2520Johnson&date=2019-01-01%202025-05-01&geo=Worldwide&gprop=web
SELECT * FROM dwaynecsv;

SELECT *
FROM dwaynecsv
WHERE `Dwayne The Ad Johnson` <> 0;

/*
Important timelines:
2020-01-01 : 100
2021-12-01 : 75
2022-04-01 : 50
*/

DESCRIBE imbd;
-- https://www.kaggle.com/code/payamamanat/imdb-movies
SELECT * FROM imbd;
SELECT COUNT(*) FROM imbd; -- 830
SELECT *
FROM imbd
WHERE Actors LIKE '%Dwayne Johnson%'; -- 10 rows returned and none after 2020, so we might have to look at a different dataset

SELECT * FROM movies_clean;
-- https://www.kaggle.com/datasets/mohammedalsubaie/movies
SELECT COUNT(*) FROM movies_clean; -- 3400
DESCRIBE movies_clean;

/* https://www.imdb.com/name/nm0425005/?ref_=fn_t_1
IMBD showing all of Dwayne's movies, we can cross reference and make a before/after 2020 (after being called out (bad publicity))
*/

CREATE TABLE dwayne_pre_2020 AS
SELECT title, release_date, revenue, budget
FROM movies_clean
WHERE title in (   'The Mummy Returns', 'The Scorpion King', 'The Rundown',
    'Walking Tall', 'Gridiron Gang', 'The Game Plan',
    'Get Smart', 'Race to Witch Mountain', 'Tooth Fairy',
    'Faster', 'Fast Five', 'Journey 2: The Mysterious Island',
    'Snitch', 'G.I. Joe: Retaliation', 'Pain & Gain',
    'Fast & Furious 6', 'Hercules', 'Furious 7',
    'San Andreas', 'Central Intelligence', 'Moana',
    'The Fate of the Furious', 'Baywatch',
    'Jumanji: Welcome to the Jungle', 'Rampage',
    'Skyscraper', 'Fighting with My Family',
    'Fast & Furious Presents: Hobbs & Shaw',
    'Jumanji: The Next Level');

CREATE TABLE dwayne_post_2020 AS
SELECT title, release_date, revenue, budget
FROM movies_clean
WHERE title in( 
'Jungle Cruise', 'Red Notice', 'Black Adam');

SELECT * FROM dwayne_pre_2020;
SELECT AVG(revenue), AVG(budget)
FROM dwayne_pre_2020;
/*
AVG revenue : $'405,686,846.1379'
AVG budget :  $'94,551,724.1379'

*/

SELECT * FROM dwayne_post_2020;
SELECT AVG(revenue), AVG(budget)
FROM dwayne_post_2020;
/*
AVG revenue : $'204,773,233.3333'
AVG budget :  $'18,6666,666.6667'
*/

SELECT AVG(revenue), AVG(budget), 
ROUND(((405686846.1379 - AVG(revenue))/405686846.1379),4) * 100 AS revenue_percent_dropoff,
ROUND(((94551724.1379 - AVG(budget))/94551724.1379),4) * 100 AS budget_percent_difference
FROM dwayne_post_2020;

/*
According to this sample space, the revenue drop off post 2020 is ~49.52% and revenue "drop off" was ~-97%, 
the negative means that budgets actually increased by 97%:
So while revenue dropped almost 50%, the budget actually increased surprisingly.

Nonetheless, it is important to note that these observations are of timeliens before/after 2020, 
when Dwayne got called out for being a walking bill board. Treating all variables as independent, we can see a correlation
between his public image, and might play a role in his revenue drop off in his projects.
*/

-- dwayne2004_to_present: https://trends.google.com/explore?q=Dwayne%2520Johnson&date=all&geo=Worldwide&gprop=web

SELECT * 
FROM dwayne2004_to_present
ORDER BY `Dwayne Johnson` DESC;

DESCRIBE dwayne2004_to_present;

SELECT YEAR(`Time`) AS 'Year', 
MAX(`Dwayne Johnson`) AS popularity
FROM dwayne2004_to_present
GROUP BY `Year`
ORDER BY popularity DESC;
/*
Top 5 Years of google searches for "Dwayne Johnson" ( in DESC ORDER)
2014: 100 (most popular year)
2019: 91
2017: 87
2018: 73
2021: 71

*/

SELECT * FROM dwayne_pre_2020
WHERE release_date LIKE '%2014%' OR release_date LIKE '%2019%' OR release_date LIKE '%2017%' OR release_date LIKE '%2018%' OR release_date LIKE '%2021%'; 
-- 9 rows returned

CREATE TABLE dwayne_popular AS
SELECT * FROM dwayne_pre_2020
WHERE release_date LIKE '%2014%' OR release_date LIKE '%2019%' OR release_date LIKE '%2017%' OR release_date LIKE '%2018%' OR release_date LIKE '%2021%'; 

SELECT AVG(revenue), AVG(budget) 
FROM dwayne_popular;
/*
Average Revenue: $552,805,424.1111 (million)
Average Budget:  $121,111,111.1111 (million)
From Dwayne's most popular years

Compared to post 2020 (post controversy)
AVG revenue : $'204,773,233.3333'
AVG budget :  $'18,6666,666.6667'

Mathematics:
~63% revenue drop
Surprisngly: ~54 budget increase on average 

Comaring Dwayne's most popular years to his fall off post 2020!

*/
SELECT * FROM dwayne2004_to_present;
-- Joins

CREATE TABLE dwayne_trends_years AS
SELECT YEAR(`Time`) AS yearly, MAX(`Dwayne Johnson`) AS prime_popularity, AVG(`Dwayne Johnson`) AS avg_popularity
FROM dwayne2004_to_present
GROUP BY yearly;

SELECT * FROM dwayne_trends_years;
SELECT * FROM dwayne_pre_2020;

SELECT d.title, d.release_date, d.revenue, d.budget, 
t.prime_popularity, t.avg_popularity
FROM dwayne_pre_2020 d
JOIN dwayne_trends_years t
ON YEAR(d.release_date) = t.yearly
ORDER BY YEAR(d.release_date); -- null values, need fixing/ adjustments in google trends timeline

SELECT DISTINCT(yearly) FROM dwayne_trends_years; -- 04 -> 2026

SELECT DISTINCT(`Year`) FROM imbd
ORDER BY `Year` ASC; -- 06 -> 2016

SELECT * FROM imbd;
SELECT * FROM dwayne2004_to_present;

SELECT * FROM dwayne_pre_2020;
SELECT * FROM dwayne_post_2020;

SELECT YEAR(release_date)
FROM dwayne_pre_2020;

CREATE TABLE dwayne_joined AS
SELECT  t.yearly,t.average_popularity, t.max_popularity,pre.title, YEAR(STR_TO_DATE(pre.release_date, '%m/%d/%Y')) AS release_year,pre.revenue, pre.budget
FROM (
SELECT YEAR(`Time`) AS yearly, AVG(`Dwayne Johnson`) AS average_popularity, MAX(`Dwayne Johnson`) AS max_popularity
FROM dwayne2004_to_present
GROUP BY YEAR(`Time`)
) t 
JOIN dwayne_pre_2020 pre
ON t.yearly = YEAR(str_to_date(pre.release_date, '%m/%d/%Y'))
UNION ALL
SELECT t.yearly, t.average_popularity, t.max_popularity, post.title,  YEAR(STR_TO_DATE(post.release_date, '%m/%d/%Y')) AS release_year, post.budget, post.revenue
FROM(
SELECT YEAR(`Time`) AS yearly, AVG(`Dwayne Johnson`)AS average_popularity, MAX(`Dwayne Johnson`) AS max_popularity
FROM dwayne2004_to_present
GROUP BY YEAR(`Time`)) t
JOIN dwayne_post_2020 post
ON t.yearly = YEAR(STR_TO_DATE(post.release_date, '%m/%d/%Y'))
ORDER BY release_year ;

SELECT * FROM dwayne_joined;


/*
dwaynecsv → Google Trends: https://trends.google.com/explore?q=Dwayne%2520The%2520Ad%2520Johnson&date=2019-01-01%202025-05-01&geo=Worldwide&gprop=web
dwayne2004_to_present → Google Trends: https://trends.google.com/explore?q=Dwayne%2520Johnson&date=all&geo=Worldwide&gprop=web
movies_clean → Kaggle (Mohammed Al Subaie): https://www.kaggle.com/datasets/mohammedalsubaie/movies
imbd → Kaggle (Payam Amanat): https://www.kaggle.com/code/payamamanat/imdb-movies*/

