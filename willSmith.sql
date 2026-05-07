-- Case study 2: Will Smith slaps Chris Rock (March 27, 2022: Negative publicity)
USE movies_publicity;

-- https://www.kaggle.com/datasets/delfinaoliva/movies?resource=download

-- 1) EDA
DESCRIBE will;
-- 16 columns

SELECT COUNT(*)
FROM will; 
-- 3,703 rows 

SELECT *
FROM will
LIMIT 50; -- Columns that have to do with oscars are all 0 from what I see

-- Compare # of oscars vs # not oscars (0 vs 1) to see if it's worth dropping these 2 columns

SELECT COUNT(*)
FROM will
WHERE `Oscar and Golden Globes nominations` =0;
-- 2,655 have 0 


SELECT COUNT(*)
FROM will
WHERE `Oscar and Golden Globes nominations` = 1;
-- 420
-- math ain't mathing

SELECT COUNT(*)
FROM will
WHERE `Oscar and Golden Globes nominations` != 0;
-- 1048, math is mathing, I suspect null values


SELECT DISTINCT(`Oscar and Golden Globes nominations`)
FROM will;
-- Oh I see, it's not just 1's and 0's, it's any real integer: I've decided it's worth keeping


SELECT COUNT(*)
FROM will 
WHERE `Actor 1` LIKE '%Will Smith%' 
OR `Actor 2` LIKE '%Will Smith%' 
OR `Actor 3` LIKE '%Will Smith%'; -- 18 movies... 18 < 30, thus a small sample size... for will smith

SELECT COUNT(*)
FROM will 
WHERE `Actor 1` LIKE '%Chris Rock%' 
OR `Actor 2` LIKE '%Chris Rock%' 
OR `Actor 3` LIKE '%Chris Rock%'; -- 0, not looking good let's see what we can gather from this one anyways

SELECT * 
FROM will
WHERE `Actor 1` LIKE '%Will Smith%' 
OR `Actor 2` LIKE '%Will Smith%' 
OR `Actor 3` LIKE '%Will Smith%';

-- Luckily this data set gives us years of the releast date of before and after 2022

CREATE TABLE will18 AS -- 18 cause he has 18 rows in this data set
SELECT * 
FROM will
WHERE `Actor 1` LIKE '%Will Smith%' 
OR `Actor 2` LIKE '%Will Smith%' 
OR `Actor 3` LIKE '%Will Smith%';

SELECT *
FROM will18;


CREATE TABLE willBefore AS
SELECT * 
FROM will18
WHERE `Release year` < 2022;

CREATE TABLE willAfter AS
SELECT * 
FROM will18
WHERE `Release year` >= 2022;


SELECT * 
FROM willBefore;

SELECT COUNT(*) 
FROM willBefore; -- 18 rows?

SELECT * 
FROM willAfter; -- SHIT THERES NOTHING HERE

/* 
Upon further research, Will Smith has only acted in 2 movies post 2022:

"Emancipation" - 2022
 "Bad Boys" - 2024

While initially I thought that a sample size of 18 rows for will smith was not good practice to work with,
after further research, WIll Smith has acted in 40 movies (population), and we have 18/40 = 0.45, which is almost
half, we can can insert the values that we wish to compare between before and after will smith 
by inserting data of these two movies

*/

INSERT INTO willAfter (`Movie`, `Actor 1`, `Release year`, `IMDb score`, `Budget`, `Box Office`, `Earnings`)
VALUES 
('Emancipation', 'Will Smith', 2022, 6.3, 141000000, 112500000, -28500000),
('Bad Boys: Ride or Die', 'Will Smith', 2024, 6.5, 100000000, 450000000, 305000000);

/*
Emancipation feature engineering:
Wikipedia says that the budget for Emancipation is 120-162 million. I will take the average of that: 141000000

Deadline.com says Apple tv paid 105 - 120 million : take the average of that for box office: 112500000
https://deadline.com/2020/07/apple-emancipation-will-smith-antoine-fuqua-record-festival-deal-runaway-slave-peter-scourged-back-photo-william-n-collage-script-1202971626/

Since:
Earnings = revenue - budget, we get earnigns = -28500000, so they lost money for emancipation
*/

/*
Bad Boys feature enginnering:
IMBD score: online
budget: 100 million wikiepedia
Box office: 405 million wikipedia
Earnings:  405 - 100 million = 305 million
*/



SELECT * FROM willAfter; -- perfect
SELECT * FROM willBefore;

SELECT `Release year` , AVG(`Running Time`), AVG(Budget), AVG(`Box Office`), AVG(Earnings), AVG(`IMDb score`)
FROM willBefore
GROUP BY `Release year`
ORDER BY `Release year`; -- will before 2022, grouped by release year, can be plotted ( data visualization)

SELECT ROUND(AVG(`Running Time`)), ROUND(AVG(Budget)), ROUND(AVG(`Box Office`)), ROUND(AVG(Earnings)), ROUND( AVG(`IMDb score`))
FROM willBefore;

/*
Averages Will Before:
Run time: 117 minutes
Budget: 108172222 (108 million)
Box office: 346705556 (347 million)
Earnings: 238533333 (239 million)
IMdb Score: 7/10
*/

SELECT `Release year` , AVG(`Running Time`), AVG(Budget), AVG(`Box Office`), AVG(Earnings), AVG(`IMDb score`)
FROM willAfter
GROUP BY `Release year`
ORDER BY `Release year`; -- Perhaps a bar graph for post 2022 

SELECT ROUND(AVG(`Running Time`)), ROUND(AVG(Budget)), ROUND(AVG(`Box Office`)), ROUND(AVG(Earnings)), ROUND( AVG(`IMDb score`))
FROM willAfter;

/*
Average for Will After:
Budget: 120500000, (121 million) Budget went up ( similar to dwayne situation)
Box office: 281250000, (281 million, didn't make as much as before 2022)
Earnings: 138250000 (138 million, also less, basic math)
imbd score: 6/10 (dropped by 1 value of 1, so did people enjoy his movies less due to his controversies? perhaps.)




Interpreting results:
After Will Smith slapped Chris Rock in 2022, we can see through the 20 total movies (18 rows /40 total movies before 2022 and 2 after 2022).
Similar to Dwayne's controvery, surprisingly, Hollywood seems to give them more of a budget for their movies. This is a trend for these two
case studies. The box office money is basically in total how much the film/project made, earnings is budget - box office, so we can think of
earnings as revenue, and budget is how much it took to make the film.alter

So budget went up on on average by ~13 million.
Box office (total money made by movie) went down by 66 million.
Earnings lost ~138 million, so losing 138 million in profits. 

Last but not least imbd score went down a point, which we can make an inference to mean people dislike his movies more, maybe even on a personal
level. 

Limitations of Will Smith CSV: again it's 18/40 total movies he's done. The data about post 2022 is manually inserted, but sources for
numbers are clarified. But 18/40 is almost have the sample space, so we can tkae the average of 18 and still tell a full story on how
this controversy negatively also influenced the acting career of Will Smith. 


Let's look at some timeline:
https://trends.google.com/explore?q=will%20smith&date=all&geo=US
A timeline from 2004 - present (2026) of searches for will smith
*/

-- https://trends.google.com/explore?q=will%20smith&date=all&geo=US

SELECT *
FROM will2004;
-- convert Time column to just be the year

SELECT YEAR(`Time`), `will smith`
FROM will2004;

SELECT YEAR(`Time`), ROUND(AVG(`will smith`))
FROM will2004
GROUP BY YEAR(`Time`)
ORDER BY YEAR(`Time`); -- plotting

SELECT YEAR(`Time`),ROUND(AVG(`will smith`))
FROM will2004
GROUP BY YEAR(`Time`)
ORDER BY AVG(`will smith`) DESC;
/*
Average Score)
2022: 14
2016: 6
2020: 5
...
*/

SELECT YEAR(`Time`), ROUND(MAX(`will smith`))
FROM will2004
GROUP BY YEAR(`Time`)
ORDER BY YEAR(`Time`); -- plotting

SELECT YEAR(`Time`),ROUND(MAX(`will smith`))
FROM will2004
GROUP BY YEAR(`Time`)
ORDER BY ROUND(MAX(`will smith`)) DESC;

/*
Max Score:

2022: 100
2020: 21
2016: 16
...


We can see that 2022 (year of the controversy) saw will smith hit a all time high in search counts, compared to other years. 
Let's take a look at searches for Chris Rock:
https://trends.google.com/explore?q=chris%2520rock&date=all&geo=US
*/

-- https://trends.google.com/explore?q=chris%2520rock&date=all&geo=US

SELECT YEAR(`Time`), ROUND(AVG(`chris rock`))
FROM chris
GROUP BY YEAR(`Time`)
ORDER BY YEAR(`Time`); -- plotting

SELECT YEAR(`Time`), ROUND(AVG(`chris rock`))
FROM chris
GROUP BY YEAR(`Time`)
ORDER BY ROUND(AVG(`chris rock`)) DESC;

/*
Average:
2022: 12
2023 : 3
2004 : 2
*/

SELECT YEAR(`Time`), ROUND(MAX(`chris rock`))
FROM chris
GROUP BY YEAR(`Time`)
ORDER BY ROUND(MAX(`chris rock`)) DESC; 

/*
Max:
Similar story to Will Smith:
2022 : 100
2023 : 20
2014 : 9
*/

-- joins

SELECT YEAR(c.`Time`) AS timeYears, MAX(c.`Chris Rock`) AS chrisRock, MAX(w.`Will Smith`) as willSmith
FROM chris c
JOIN will2004 w
ON YEAR(c.`Time`) = YEAR(w.`Time`)
GROUP BY YEAR(c.`Time`) ; -- plotting

