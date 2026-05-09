USE cinemaload;

CREATE TABLE chrisBefore AS
SELECT ROUND(AVG(budget_usd)) AS budget,
ROUND(AVG(revenue_usd)) AS revenue, 
ROUND(AVG(runtime_min)) AS runtime, 
ROUND(AVG(vote_average)) AS vote, 
ROUND(AVG(popularity)) AS popularity,
ROUND(AVG(revenue_usd)) - ROUND(AVG(budget_usd)) AS profit
FROM chris 
WHERE release_year < 2022;

/*
Chris before 2022 averages:
Budget: $14.7 million
Revenue: $43.4 million
Runtime: 93 minutes
Profit: $28.7 million
Vote Avg:6 / 10
Popularity:2
*/

CREATE TABLE chrisAfter AS
SELECT ROUND(AVG(budget_usd)) AS budget,
ROUND(AVG(revenue_usd)) AS revenue, 
ROUND(AVG(runtime_min)) AS runtime, 
ROUND(AVG(vote_average)) AS vote, 
ROUND(AVG(popularity)) AS popularity,
ROUND(AVG(revenue_usd)) - ROUND(AVG(budget_usd)) AS profit
FROM chris 
WHERE release_year >= 2022;

SELECT * FROM chrisbefore;
SELECT * FROM chrisafter;
/*
Chris After 2022 Averages:

Budget:$6.9 million
Revenue:$14.6 million
Profit: $7.7 million
runtime: 93 minutes
Vote Avg:5 / 10
Popularity: 2
*/




-- Will
SELECT COUNT(*)
FROM will; 

SELECT * FROM will;


SELECT COUNT(*)
FROM will 
WHERE `Actor 1` LIKE '%Will Smith%' 
OR `Actor 2` LIKE '%Will Smith%' 
OR `Actor 3` LIKE '%Will Smith%';


CREATE TABLE will20 AS
SELECT *
FROM will 
WHERE `Actor 1` LIKE '%Will Smith%' 
OR `Actor 2` LIKE '%Will Smith%' 
OR `Actor 3` LIKE '%Will Smith%'; -- 20 this time? huh? whatever....

SELECT * FROM will20;

-- CREATE TABLE willBefore AS
-- SELECT * 
-- FROM will20
-- WHERE `Release year` < 2022;

-- SELECT * FROM willBefore;

CREATE TABLE willAfter AS
SELECT * 
FROM will20
WHERE `Release year` >= 2022;

INSERT INTO willAfter (`Movie`, `Actor 1`, `Release year`, `IMDb score`, `Budget`, `Box Office`, `Earnings`)
VALUES 
('Emancipation', 'Will Smith', 2022, 6.3, 141000000, 112500000, -28500000),
('Bad Boys: Ride or Die', 'Will Smith', 2024, 6.5, 100000000, 450000000, 305000000);


SELECT * FROM willAfter;


CREATE TABLE willAverageBefore AS
SELECT `Release year` , AVG(`Running Time`), AVG(Budget), AVG(`Box Office`), AVG(Earnings), AVG(`IMDb score`)
FROM will20
GROUP BY `Release year`
ORDER BY `Release year`;

SELECT * FROM willAverageBefore;

SELECT ROUND(AVG(`Running Time`)), ROUND(AVG(Budget)), ROUND(AVG(`Box Office`)), ROUND(AVG(Earnings)), ROUND( AVG(`IMDb score`))
FROM will20;

SELECT *
FROM willTime;

SELECT YEAR(`Time`), `will smith`
FROM willTime;

SELECT YEAR(`Time`) AS `Year`, ROUND(MAX(`will smith`)) AS popularity
FROM willTime
GROUP BY YEAR(`Time`)
ORDER BY YEAR(`Time`); -- plotting, since averages are skewed, we should look at the max for popularity


SELECT YEAR(`Time`) AS `Year`, ROUND(MAX(`chris rock`)) AS popularity
FROM chrisTime
GROUP BY YEAR(`Time`)
ORDER BY YEAR(`Time`); 

SELECT * FROM dwaynetime;
SELECT * FROM dwayneadtime;

SELECT YEAR(`Time`) AS `Year`, MAX(`Dwayne Johnson`) AS popularity
FROM dwaynetime
GROUP BY `Year`
ORDER BY `Year`;

SELECT YEAR(`Time`) AS `Year`, MAX(`Dwayne The Ad Johnson`) AS popularity
FROM dwayneadtime
GROUP BY `Year`
ORDER BY `Year`;


DESCRIBE dwayne;
SELECT COUNT(*) FROM dwayne;
SELECT * FROM dwayne;

SELECT DISTINCT(YEAR(release_date)) FROM dwayne;

SELECT * FROM dwayne;

SELECT DISTINCT(YEAR(STR_TO_DATE(release_date, '%m/%d/%Y'))) AS `Year` 
FROM dwayne
ORDER BY `Year`;

CREATE TABLE dwaynebefore AS
SELECT (YEAR(STR_TO_DATE(release_date, '%m/%d/%Y'))) AS `Year`, vote_average, revenue, budget
FROM dwayne
WHERE (YEAR(STR_TO_DATE(release_date, '%m/%d/%Y'))) < 2020
ORDER BY `Year`;

SELECT * FROM dwaynebefore;

SELECT  AVG(vote_average) AS averageVote, AVG(revenue) AS avg_revenue, AVG(budget) as avg_budget
FROM dwaynebefore
-- GROUP BY `Year`
ORDER BY `Year`;

SELECT * FROM dwayne;

CREATE TABLE dwayneafter AS
SELECT title, (YEAR(STR_TO_DATE(release_date, '%m/%d/%Y'))) AS `Year`, vote_average, revenue, budget
FROM dwayne
WHERE (YEAR(STR_TO_DATE(release_date, '%m/%d/%Y'))) >= 2020
ORDER BY `Year`;

SELECT * FROM dwayneafter;

SELECT  AVG(vote_average), AVG(revenue), AVG(budget)
FROM dwayneafter
-- GROUP BY `Year`
ORDER BY `Year`;

/*
Before Average:
 Avg Vote:     6.1 / 10
  Avg Revenue:  $308.8 million
  Avg Budget:   $78.7 million

After Average:
Vote : 5.9
Revenue: $430.2 million
Budget:  $197.0 million

*/
SELECT AVG(vote_average), AVG(revenue), AVG(budget)
FROM dwayneafter
WHERE title <> 'Moana 2'
ORDER BY `Year`;

/*
post 2020 averages:

Avg Vote: 5.9 / 10
Avg Revenue: $430.2 million
Avg Budget: $197.0 million

And without Moana 2:
Avg Vote: 7.2 / 10
Avg Revenue: $304.4 million
Avg Budget: $206.0 million

When looking at his live actions, it is clear that the revenue and budget went down. Moana 2 builds off of the success from moana 1, so we should keep that in mind
when looking at Dwayne's story
*/
CREATE TABLE moana2016 AS 
SELECT revenue, budget, vote_average
FROM dwayne
WHERE title = 'Moana';

SELECT * FROM moana2016;

CREATE TABLE moana2 AS
SELECT revenue, budget, vote_average
FROM dwayne
WHERE title = 'Moana 2';

SET SQL_SAFE_UPDATES = 0;
SELECT * FROM moana2;
UPDATE moana2
SET vote_average = 6.8;




/*

Moana (2016):
Revenue: $690.9 million
Budget: $150.0 million
Vote:7.6 / 10


Moana 2 (2024):
Revenue: $1.059 billion
Budget: $150.0 million
Vote:   6.3 / 10  (no rating data in dataset, but oneline says 6.3) -- > budget stayed the same, revenue went up by almost 2x, but vote went down
*/

