USE publicity_movies;
-- analyzing how 2022 controversy affected Chris Rock
-- https://api.themoviedb.org/3/search/person?query=Chris+Rock&api_key=210e0db7be7021b41723ab14dad354ce
DESCRIBE chris;

SELECT * 
FROM chris;

SELECT MAX(popularity), MIN(popularity)
FROM chris; -- Max: 14.2, min: 0.1444

CREATE TABLE chrisBefore AS
SELECT ROUND(AVG(budget_usd)),ROUND(AVG(revenue_usd)), ROUND(AVG(runtime_min)), ROUND(AVG(vote_average)), ROUND(AVG(popularity)),
ROUND(AVG(revenue_usd)) - ROUND(AVG(budget_usd)) AS average_profit
FROM chris 
WHERE release_year < 2022;

SELECT * 
FROM chrisBefore;

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
SELECT ROUND(AVG(budget_usd)),ROUND(AVG(revenue_usd)), ROUND(AVG(runtime_min)), ROUND(AVG(vote_average)), ROUND(AVG(popularity)),
ROUND(AVG(revenue_usd)) - ROUND(AVG(budget_usd)) AS average_profit
FROM chris 
WHERE release_year >= 2022;

SELECT * 
FROm chrisAfter;

/*
Chris After 2022 Averages:

Budget:$6.9 million
Revenue:$14.6 million
Profit: $7.7 million
runtime: 93 minutes
Vote Avg:5 / 10
Popularity: 2
*/

/*
initially I thought that since Chris Rock was the person who is the "victim" in this situation,
we can see that not only did his average revenue go down, we can also see teh budget on his films also went down.
This contrasts Dwayne and Will Smith, where after their controversies, their budgets went up, but similiarly their revenue went down for their projects.
And as we might suspect, since profit = revenue - budget, we can also use feature engineering to see that the average profit before 2022: $28.7 million
to after: $7.7 million also went down. 

To be more mathematical, the % drop is:
((post 2022 - before 2022)/ before 2022)
This give sus - 73% drop in profits for Chris Rock movies
*/


