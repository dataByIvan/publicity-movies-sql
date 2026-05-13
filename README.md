BSDS 200 Final Project SQL Review Guide
Group: Ivan, Lhea, Matthew
Topic: Movie publicity, online attention, and box office revenue

Analyzing the influences of HollyWood stars before and after their controversies.
Metrics of "success" can include but not limited to google trends searches, revenue, budgets, profits from their projects/movies. 


API puller for Dwayne: 
https://github.com/qb125/TMDB-Movie-Data-Scraper/blob/main/main.py

Main research question:
How are different types of online publicity, including negative backlash and positive virality, associated with movie box office revenue?

Files to review:

1. lhea_positive_publicity.sql
Purpose:
This file contains Lhea’s positive-publicity case study on Barbie, The Super Mario Bros. Movie, and A Minecraft Movie. It loads Google Trends tables, checks the movies_clean revenue table, creates the positive_publicity_examples table, and produces analysis queries used for the five positive-publicity visualizations.

Main outputs:
- Google Trends search interest over time
- worldwide revenue vs. production budget
- ROI comparison
- months with search interest above 10/100
- domestic vs. international revenue

2. DSProject_EzraMiller.sql
Purpose:
This file contains Matthew’s Ezra Miller negative-publicity analysis. It compares search attention, revenue activity, and movie frequency over time. The final plot normalizes these measures to a 0–100 scale.

Main output:
- Ezra Miller search attention vs. box office activity plot

3. movies_and_publicity.sql / dataUnloadedVisualize.sql
Purpose:
These files include Dwayne Johnson, Will Smith, and Chris Rock case-study analysis. They compare movie revenue, Google Trends attention, and before/after publicity periods.

Main outputs:
- Dwayne revenue/profit/popularity visualizations
- Will Smith before/after revenue and search trends
- Chris Rock before/after revenue and search trends

Notes:
The GitHub repository contains extra working files, but the files listed above are the main files for grading.
