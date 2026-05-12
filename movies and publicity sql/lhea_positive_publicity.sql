/* 
   LHEA SECTION: POSITIVE PUBLICITY CASE STUDIES
   Author: Lhea

   Purpose:
   This section focuses only on positive online publicity.
   I am comparing movies where social media attention worked more like hype,
   memes, fandom, nostalgia, and audience participation instead of backlash.

   Main idea:
   Positive publicity can make a movie feel like a cultural event. For this
   section, I am using Barbie, The Super Mario Bros. Movie, and A Minecraft Movie
   as examples of hype-driven publicity.

   Dataset references:
   1. movies_clean
      - Main movie revenue dataset from Kaggle/movie revenue data.
      - Used for movie title, year, worldwide revenue, domestic revenue,
        genre, rating, and vote count when available.

   2. Google Trends CSV exports (9 tables total across 3 movies)
      - Used to measure online search interest over time.
      - This is not actual search count. It is relative search interest 0-100.
      - Tables: barbie_trends_time_series, barbie_top_search_query,
        barbie_with_rising_queries, minecraft_movie_time_series,
        minecraft_movie_top_queries, minecraft_movie_rising_queries,
        supermario_time_series, supermario_bros_top_queries,
        supermario_bros_rising_queries

   3. positive_publicity_examples (hand-built table)
      - Created manually for this section because A Minecraft Movie (2025)
        may not appear in movies_clean yet.
      - Also lets me compare all three movies in one place.
  */

USE case_studies;

-- =====================================================================
-- SECTION ONE: EXPLORATORY DATA ANALYSIS
-- =====================================================================

-- --- Time Series Tables ---

-- How many monthly data points do we have per movie?
SELECT COUNT(*) AS row_count FROM barbie_trends_time_series;
SELECT COUNT(*) AS row_count FROM minecraft_movie_time_series;
SELECT COUNT(*) AS row_count FROM supermario_time_series;

-- Date range for all three time series (should all match: 2018-05 to 2026-05)
SELECT MIN(Time) AS earliest, MAX(Time) AS latest FROM barbie_trends_time_series;
SELECT MIN(Time) AS earliest, MAX(Time) AS latest FROM minecraft_movie_time_series;
SELECT MIN(Time) AS earliest, MAX(Time) AS latest FROM supermario_time_series;

-- What was peak search interest and when did it happen?
-- Barbie peaked July 2023, Super Mario peaked April 2023, Minecraft peaked April 2025
SELECT Time, `barbie movie` AS search_interest
FROM barbie_trends_time_series
ORDER BY `barbie movie` DESC
LIMIT 5;

SELECT Time, `minecraft movie` AS search_interest
FROM minecraft_movie_time_series
ORDER BY `minecraft movie` DESC
LIMIT 5;

SELECT Time, `The Super Mario Bros. Movie` AS search_interest
FROM supermario_time_series
ORDER BY `The Super Mario Bros. Movie` DESC
LIMIT 5;

-- Check for NULLs in each time series
SELECT COUNT(*) AS null_count FROM barbie_trends_time_series
WHERE Time IS NULL OR `barbie movie` IS NULL;

SELECT COUNT(*) AS null_count FROM minecraft_movie_time_series
WHERE Time IS NULL OR `minecraft movie` IS NULL;

SELECT COUNT(*) AS null_count FROM supermario_time_series
WHERE Time IS NULL OR `The Super Mario Bros. Movie` IS NULL;

-- --- Top Queries Tables ---

-- How many query rows per movie?
SELECT COUNT(*) AS row_count FROM barbie_top_search_query;
SELECT COUNT(*) AS row_count FROM minecraft_movie_top_queries;
SELECT COUNT(*) AS row_count FROM supermario_bros_top_queries;

-- What are the top 5 most searched queries per movie?
SELECT query, `search interest` FROM barbie_top_search_query
ORDER BY `search interest` DESC LIMIT 5;

SELECT query, `search interest` FROM minecraft_movie_top_queries
ORDER BY `search interest` DESC LIMIT 5;

SELECT query, `search interest` FROM supermario_bros_top_queries
ORDER BY `search interest` DESC LIMIT 5;

-- --- Rising Queries Tables ---

-- Top 5 breakout (rising) queries per movie
SELECT query, `search interest`, `increase percent` FROM barbie_with_rising_queries
ORDER BY `search interest` DESC LIMIT 5;

SELECT query, `search interest`, `increase percent` FROM minecraft_movie_rising_queries
ORDER BY `search interest` DESC LIMIT 5;

SELECT query, `search interest`, `increase percent` FROM supermario_bros_rising_queries
ORDER BY `search interest` DESC LIMIT 5;


-- =====================================================================
-- SECTION TWO: DATA CLEANING
-- =====================================================================

-- The time series tables use a VARCHAR date format (YYYY-MM-DD).
-- Converting to DATE type in queries so we can do date comparisons properly.
-- Note: if loading into MySQL, set the column type to DATE on import.

-- Check that all Time values parse correctly as dates (no bad formats)
SELECT Time FROM barbie_trends_time_series
WHERE STR_TO_DATE(Time, '%Y-%m-%d') IS NULL;

SELECT Time FROM minecraft_movie_time_series
WHERE STR_TO_DATE(Time, '%Y-%m-%d') IS NULL;

SELECT Time FROM supermario_time_series
WHERE STR_TO_DATE(Time, '%Y-%m-%d') IS NULL;

-- The `increase percent` column is a VARCHAR (contains values like '-40%', 'Breakout').
-- We cannot use it as a number directly. For analysis, we will treat 'Breakout'
-- as a separate category and ignore the % symbol in other values.

-- How many rows have 'Breakout' vs a numeric percent in barbie rising queries?
SELECT
    CASE
        WHEN `increase percent` = 'Breakout' THEN 'Breakout'
        ELSE 'Numeric percent'
    END AS percent_type,
    COUNT(*) AS num_rows
FROM barbie_with_rising_queries
GROUP BY percent_type;

-- Same check for Minecraft and Super Mario
SELECT
    CASE WHEN `increase percent` = 'Breakout' THEN 'Breakout' ELSE 'Numeric percent' END AS percent_type,
    COUNT(*) AS num_rows
FROM minecraft_movie_rising_queries
GROUP BY percent_type;

SELECT
    CASE WHEN `increase percent` = 'Breakout' THEN 'Breakout' ELSE 'Numeric percent' END AS percent_type,
    COUNT(*) AS num_rows
FROM supermario_bros_rising_queries
GROUP BY percent_type;


-- =====================================================================
-- SECTION THREE: JOINING TABLES
-- =====================================================================

-- Join all three time series on the shared Time column.
-- Using INNER JOIN because we only want months that exist in all three tables.
-- All three share the same 2018-2026 range so no rows should be lost.
SELECT
    bts.Time,
    bts.`barbie movie`                    AS barbie_interest,
    mts.`minecraft movie`                 AS minecraft_interest,
    sts.`The Super Mario Bros. Movie`     AS mario_interest
FROM barbie_trends_time_series bts
JOIN minecraft_movie_time_series mts
    ON bts.Time = mts.Time
JOIN supermario_time_series sts
    ON bts.Time = sts.Time
ORDER BY bts.Time;

-- Compare search interest for the months around each movie's release.
-- Barbie released July 2023, Mario released April 2023, Minecraft released April 2025.
SELECT
    bts.Time,
    bts.`barbie movie`                AS barbie_interest,
    mts.`minecraft movie`             AS minecraft_interest,
    sts.`The Super Mario Bros. Movie` AS mario_interest
FROM barbie_trends_time_series bts
JOIN minecraft_movie_time_series mts ON bts.Time = mts.Time
JOIN supermario_time_series sts      ON bts.Time = sts.Time
WHERE bts.Time BETWEEN '2023-01-01' AND '2025-12-01'
ORDER BY bts.Time;

-- Join positive_publicity_examples back to movies_clean.
-- Using LEFT JOIN because A Minecraft Movie (2025) may not exist in movies_clean yet.
-- LEFT JOIN keeps all three of my case study movies even if there is no match.
SELECT
    p.movie_title,
    p.release_year,
    p.publicity_type,
    p.attention_style,
    p.worldwide_revenue  AS case_table_worldwide,
    m.`Release Group`,
    m.`$Worldwide`       AS movies_clean_worldwide,
    m.`$Domestic`        AS movies_clean_domestic,
    m.Genres,
    m.Rating,
    m.Vote_Count
FROM positive_publicity_examples p
LEFT JOIN movies_clean m
    ON p.movie_title = m.`Release Group`
ORDER BY p.release_year;


-- =====================================================================
-- SECTION FOUR: ANALYSIS
-- =====================================================================

-- Build the positive_publicity_examples table
DROP TABLE IF EXISTS positive_publicity_examples;

CREATE TABLE positive_publicity_examples (
    case_id           INT PRIMARY KEY,
    movie_title       VARCHAR(255),
    release_year      INT,
    publicity_type    VARCHAR(100),
    attention_style   VARCHAR(255),
    worldwide_revenue BIGINT,
    domestic_revenue  BIGINT,
    budget            BIGINT,
    reason_for_including TEXT,
    data_reference    TEXT
);

INSERT INTO positive_publicity_examples
(case_id, movie_title, release_year, publicity_type, attention_style,
 worldwide_revenue, domestic_revenue, budget, reason_for_including, data_reference)
VALUES
(1, 'A Minecraft Movie', 2025, 'positive virality',
 'memes, chicken jockey trend, gaming fandom, audience participation',
 960387780, 424087780, 150000000,
 'Main positive-publicity example: movie became heavily tied to memes, gaming culture, and audience participation.',
 'Box Office Mojo 2025'),
(2, 'Barbie', 2023, 'positive virality',
 'Barbenheimer, outfits, nostalgia, memes, event-style marketing',
 1448000000, 636800000, 145000000,
 'Strong positive-publicity example: movie became a cultural event through social media and audience participation.',
 'movies_clean / Box Office Mojo'),
(3, 'The Super Mario Bros. Movie', 2023, 'positive virality',
 'video game fandom, nostalgia, memes, family audience',
 1360000000, 574000000, 100000000,
 'Gaming/fandom comparison point alongside Minecraft.',
 'movies_clean / Box Office Mojo');

-- All three case study movies
SELECT * FROM positive_publicity_examples ORDER BY worldwide_revenue DESC;

-- ROI (return on investment) for each movie
-- ROI = (worldwide revenue - budget) / budget * 100
SELECT
    movie_title,
    release_year,
    worldwide_revenue,
    budget,
    worldwide_revenue - budget                              AS estimated_profit,
    ROUND((worldwide_revenue - budget) / budget * 100, 1)  AS roi_percent
FROM positive_publicity_examples
ORDER BY roi_percent DESC;

-- Average revenue, budget, and profit across the three positive-publicity movies
SELECT
    COUNT(*)                                    AS num_movies,
    ROUND(AVG(worldwide_revenue), 0)            AS avg_worldwide_revenue,
    ROUND(AVG(domestic_revenue), 0)             AS avg_domestic_revenue,
    ROUND(AVG(budget), 0)                       AS avg_budget,
    ROUND(AVG(worldwide_revenue - budget), 0)   AS avg_estimated_profit
FROM positive_publicity_examples;

-- What was peak search interest in the month each movie released?
-- This connects Google Trends data to box office performance.
SELECT
    p.movie_title,
    p.release_year,
    p.worldwide_revenue,
    CASE p.movie_title
        WHEN 'Barbie'                        THEN (SELECT `barbie movie` FROM barbie_trends_time_series WHERE Time = '2023-07-01')
        WHEN 'The Super Mario Bros. Movie'   THEN (SELECT `The Super Mario Bros. Movie` FROM supermario_time_series WHERE Time = '2023-04-01')
        WHEN 'A Minecraft Movie'             THEN (SELECT `minecraft movie` FROM minecraft_movie_time_series WHERE Time = '2025-04-01')
    END AS peak_search_interest
FROM positive_publicity_examples p
ORDER BY peak_search_interest DESC;

-- How many months did each movie stay above 10 (out of 100) search interest?
-- This measures how long the hype lasted, not just how big the peak was.
SELECT 'Barbie' AS movie, COUNT(*) AS months_above_10
FROM barbie_trends_time_series WHERE `barbie movie` > 10
UNION ALL
SELECT 'Minecraft Movie', COUNT(*)
FROM minecraft_movie_time_series WHERE `minecraft movie` > 10
UNION ALL
SELECT 'Super Mario Bros Movie', COUNT(*)
FROM supermario_time_series WHERE `The Super Mario Bros. Movie` > 10;

/* Interpretation:
   My section shows that online attention does not always mean backlash.
   Barbie, Super Mario, and Minecraft are examples where the attention was
   more connected to excitement, memes, nostalgia, and audience participation.

   All three movies had ROI well above 500%, suggesting positive virality
   may amplify the impact of already strong brands and marketing campaigns.

   Peak Google Trends interest (all hitting 100/100) aligned with release
   month for all three movies, supporting the idea that hype-driven publicity
   concentrates attention around the theatrical window.

   I am not claiming social media caused the revenue by itself. These movies
   also had large marketing campaigns, wide releases, and built-in fan bases.
   My point is that positive publicity creates a different pattern from negative
   publicity because the attention is participatory and hype-driven.
*/
