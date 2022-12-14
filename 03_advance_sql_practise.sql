-- ADVANCE LEVEL 

-- SQL Data Types
/*Convert the funding_total_usd and founded_at_clean columns in the tutorial.crunchbase_companies_clean_date table 
 to strings (varchar format) using a different formatting function for each one.*/
SELECT
  CAST(funding_total_usd AS varchar) AS funding_total_usd_string,
  CAST(founded_at_clean AS varchar) AS founded_at_clean_string
FROM
  tutorial.crunchbase_companies_clean_date 
  
  
-- SQL Date Format  
/*Write a query that counts the number of companies acquired within 3 years, 5 years, and 
10 years of being founded (in 3 separate columns). Include a column for total companies 
acquired as well. Group by category and limit to only rows with a founding date.*/
SELECT
  companies.category_code,
  COUNT(
    CASE
      WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean :: timestamp + INTERVAL '3 years' THEN 1
      ELSE NULL
    END
  ) AS acquired_3_yrs,
  COUNT(
    CASE
      WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean :: timestamp + INTERVAL '5 years' THEN 1
      ELSE NULL
    END
  ) AS acquired_5_yrs,
  COUNT(
    CASE
      WHEN acquisitions.acquired_at_cleaned <= companies.founded_at_clean :: timestamp + INTERVAL '10 years' THEN 1
      ELSE NULL
    END
  ) AS acquired_10_yrs,
  COUNT(1) AS total
FROM
  tutorial.crunchbase_companies_clean_date companies
  JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions ON acquisitions.company_permalink = companies.permalink
WHERE
  founded_at_clean IS NOT NULL
GROUP BY
  1
ORDER BY
  5 DESC 
  
  
--Using SQL String Functions to Clean Data
/*Write a query that separates the `location` field into separate fields for latitude and longitude. 
You can compare your results against the actual `lat` and `lon` fields in the table.*/
SELECT
  location,
  TRIM(
    LEADING '('
    FROM
      LEFT(location, POSITION(',' IN location) - 1)
  ) AS lattitude,
  TRIM(
    TRAILING ')'
    FROM
      RIGHT(
        location,
        LENGTH(location) - POSITION(',' IN location)
      )
  ) AS longitude
FROM
  tutorial.sf_crime_incidents_2014_01
  
 /*Concatenate the lat and lon fields to form a field that is equivalent to the location field.
  (Note that the answer will have a different decimal precision.)*/
SELECT
  CONCAT('(', lat, ', ', lon, ')') AS concat_location,
  location
FROM
  tutorial.sf_crime_incidents_2014_01
  
 /* Create the same concatenated location field, but using the || syntax instead of CONCAT.*/
SELECT
  '(' || lat || ', ' || lon || ')' AS concat_location,
  location
FROM
  tutorial.sf_crime_incidents_2014_01
  
/* Write a query that creates a date column formatted YYYY-MM-DD.*/
SELECT
  incidnt_num,
  category,
  UPPER(LEFT(category, 1)) || LOWER(RIGHT(category, LENGTH(category) - 1)) AS category_cleaned
FROM
  tutorial.sf_crime_incidents_2014_01
  
/*Write a query that returns the `category` field, but with the first letter 
capitalized and the rest of the letters in lower-case.*/
SELECT
  incidnt_num,
  category,
  UPPER(LEFT(category, 1)) || LOWER(RIGHT(category, LENGTH(category) - 1)) AS category_cleaned
FROM
  tutorial.sf_crime_incidents_2014_01
  
/*Write a query that creates an accurate timestamp using the date and time columns 
in tutorial.sf_crime_incidents_2014_01. Include a field that is exactly 1 week later as well.*/
SELECT
  incidnt_num,
  (
    SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00'
  ) :: timestamp AS timestamp,
  (
    SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2) || ' ' || time || ':00'
  ) :: timestamp + INTERVAL '1 week' AS timestamp_plus_interval
FROM
  tutorial.sf_crime_incidents_2014_01
  
/*Write a query that counts the number of incidents reported by week. 
Cast the week as a date to get rid of the hours/minutes/seconds.*/
SELECT
  DATE_TRUNC('week', cleaned_date) :: date AS week_beginning,
  COUNT(*) AS incidents
FROM
  tutorial.sf_crime_incidents_cleandate
GROUP BY
  1
ORDER BY
  1
  
/* Write a query that shows exactly how long ago each indicent was reported.
Assume that the dataset is in Pacific Standard Time (UTC - 8).*/
SELECT
  incidnt_num,
  cleaned_date,
  NOW() AT TIME ZONE 'PST' AS NOW,
  NOW() AT TIME ZONE 'PST' - cleaned_date AS time_ago
FROM
  tutorial.sf_crime_incidents_cleandate
  
/*
COALESCE
Occasionally, you will end up with a dataset that has some nulls that you'd prefer to contain actual values. 
This happens frequently in numerical data (displaying nulls as 0 is often preferable), and 
when performing outer joins that result in some unmatched rows. In cases like this, you can use COALESCE to replace the null values:*/
SELECT
  incidnt_num,
  descript,
  COALESCE(descript, 'No Description')
FROM
  tutorial.sf_crime_incidents_cleandate
ORDER BY
  descript DESC 
  
  
 -- Writing Subqueries in SQL
/*Write a query that selects all Warrant Arrests from the tutorial.sf_crime_incidents_2014_01 dataset, 
then wrap it in an outer query that only displays unresolved incidents.*/
SELECT
  sub.*
FROM
  (
    SELECT
      *
    FROM
      tutorial.sf_crime_incidents_2014_01
    WHERE
      descript = 'WARRANT ARREST'
  ) sub
WHERE
  sub.resolution = 'NONE'
  
/*Write a query that displays the average number of monthly incidents for each category. 
Hint: use tutorial.sf_crime_incidents_cleandate to make your life a little easier.*/
SELECT
  sub.category,
  AVG(sub.incidents) AS avg_incidents_per_month
FROM
  (
    SELECT
      EXTRACT(
        'month'
        FROM
          cleaned_date
      ) AS MONTH,
      category,
      COUNT(1) AS incidents
    FROM
      tutorial.sf_crime_incidents_cleandate
    GROUP BY
      1,
      2
  ) sub
GROUP BY
  1
  
  /*Write a query that displays all rows from the three categories with the fewest incidents reported.*/
SELECT
  incidents.*,
  sub.count AS total_incidents_in_category
FROM
  tutorial.sf_crime_incidents_2014_01 incidents
  JOIN (
    SELECT
      category,
      COUNT(*) AS count
    FROM
      tutorial.sf_crime_incidents_2014_01
    GROUP BY
      1
    ORDER BY
      2
    LIMIT
      3
  ) sub ON sub.category = incidents.category 
  
 /*Write a query that counts the number of companies founded and acquired by quarter starting in Q1 2012. 
  Create the aggregations in two separate queries, then join them. */
SELECT
  COALESCE(companies.quarter, acquisitions.quarter) AS quarter,
  companies.companies_founded,
  acquisitions.companies_acquired
FROM
  (
    SELECT
      founded_quarter AS quarter,
      COUNT(permalink) AS companies_founded
    FROM
      tutorial.crunchbase_companies
    WHERE
      founded_year >= 2012
    GROUP BY
      1
  ) companies
  LEFT JOIN (
    SELECT
      acquired_quarter AS quarter,
      COUNT(DISTINCT company_permalink) AS companies_acquired
    FROM
      tutorial.crunchbase_acquisitions
    WHERE
      acquired_year >= 2012
    GROUP BY
      1
  ) acquisitions ON companies.quarter = acquisitions.quarter
ORDER BY
  1
  
/*Write a query that ranks investors from the combined dataset above by the total number of investments they have made.*/
SELECT
  investor_name,
  COUNT(*) AS investments
FROM
  (
    SELECT
      *
    FROM
      tutorial.crunchbase_investments_part1
    UNION
    ALL
    SELECT
      *
    FROM
      tutorial.crunchbase_investments_part2
  ) sub
GROUP BY
  1
ORDER BY
  2 DESC
  
/*Write a query that does the same thing as in the previous problem, except only for companies that are still operating. 
Hint: operating status is in tutorial.crunchbase_companies.*/
SELECT
  investments.investor_name,
  COUNT(investments.*) AS investments
FROM
  tutorial.crunchbase_companies companies
  JOIN (
    SELECT
      *
    FROM
      tutorial.crunchbase_investments_part1
    UNION
    ALL
    SELECT
      *
    FROM
      tutorial.crunchbase_investments_part2
  ) investments ON investments.company_permalink = companies.permalink
WHERE
  companies.status = 'operating'
GROUP BY
  1
ORDER BY
  2 DESC 
  
  
  --SQL Window Functions
/*Write a query modification of the above example query that shows the duration of each ride 
as a percentage of the total time accrued by riders from each start_terminal*/
SELECT
  start_terminal,
  duration_seconds,
  SUM(duration_seconds) OVER (PARTITION BY start_terminal) AS start_terminal_sum,
  (
    duration_seconds / SUM(duration_seconds) OVER (PARTITION BY start_terminal)
  ) * 100 AS pct_of_total_time
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08'
ORDER BY
  1,
  4 DESC
  
/*Write a query that shows a running total of the duration of bike rides (similar to the last example), 
but grouped by end_terminal, and with ride duration sorted in descending order.*/
SELECT
  end_terminal,
  duration_seconds,
  SUM(duration_seconds) OVER (
    PARTITION BY end_terminal
    ORDER BY
      duration_seconds DESC
  ) AS running_total
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08'
  
/*Write a query that shows the 5 longest rides from each starting terminal, ordered by terminal, and 
longest to shortest rides within each terminal. Limit to rides that occurred before Jan. 8, 2012.*/
SELECT
  *
FROM
  (
    SELECT
      start_terminal,
      start_time,
      duration_seconds AS trip_time,
      RANK() OVER (
        PARTITION BY start_terminal
        ORDER BY
          duration_seconds DESC
      ) AS rank
    FROM
      tutorial.dc_bikeshare_q1_2012
    WHERE
      start_time < '2012-01-08'
  ) sub
WHERE
  sub.rank <= 5
  
/*Write a query that shows only the duration of the trip and the percentile into which that duration falls 
(across the entire dataset—not partitioned by terminal).*/
SELECT
  duration_seconds,
  NTILE(100) OVER (
    ORDER BY
      duration_seconds
  ) AS percentile
FROM
  tutorial.dc_bikeshare_q1_2012
WHERE
  start_time < '2012-01-08'
ORDER BY
  1 DESC 
  
  
  -- Performance Tuning SQL Queries
/*There are 26,298 rows in benn.college_football_players. That means that 26,298 rows need to be evaluated for matches in the other table. 
But if the benn.college_football_players table was pre-aggregated, 
you could reduce the number of rows that need to be evaluated in the join. First, let's look at the aggregation:*/
SELECT
  players.school_name,
  COUNT(*) AS players
FROM
  benn.college_football_players players
GROUP BY
  1
  
/*The above query returns 252 results. So dropping that in a subquery and 
then joining to it in the outer query will reduce the cost of the join substantially:*/
SELECT
  teams.conference,
  sub.*
FROM
  (
    SELECT
      players.school_name,
      COUNT(*) AS players
    FROM
      benn.college_football_players players
    GROUP BY
      1
  ) sub
  JOIN benn.college_football_teams teams ON teams.school_name = sub.school_name 
  
  
-- Pivoting Data in SQL
/*Let's start by aggregating the data to show the number of players of each year in each conference, 
similar to the first example in the inner join lesson:*/
SELECT
  teams.conference AS conference,
  players.year,
  COUNT(1) AS players
FROM
  benn.college_football_players players
  JOIN benn.college_football_teams teams ON teams.school_name = players.school_name
GROUP BY
  1,
  2
ORDER BY
  1,
  2 VIEW this IN MODE.
  
/*In order to transform the data, we'll need to put the above query into a subquery. 
It can be helpful to create the subquery and select all columns from it before starting to make transformations. 
Re-running the query at incremental steps like this makes it easier to debug if your query doesn't run. 
Note that you can eliminate the ORDER BY clause from the subquery since we'll reorder the results in the outer query.*/
SELECT
  *
FROM
  (
    SELECT
      teams.conference AS conference,
      players.year,
      COUNT(1) AS players
    FROM
      benn.college_football_players players
      JOIN benn.college_football_teams teams ON teams.school_name = players.school_name
    GROUP BY
      1,
      2
  ) sub
  
/*Assuming that works as planned (results should look exactly the same as the first query), 
it's time to break the results out into different columns for various years. 
Each item in the SELECT statement creates a column, 
so you'll have to create a separate column for each year:*/
SELECT
  conference,
  SUM(
    CASE
      WHEN year = 'FR' THEN players
      ELSE NULL
    END
  ) AS fr,
  SUM(
    CASE
      WHEN year = 'SO' THEN players
      ELSE NULL
    END
  ) AS so,
  SUM(
    CASE
      WHEN year = 'JR' THEN players
      ELSE NULL
    END
  ) AS jr,
  SUM(
    CASE
      WHEN year = 'SR' THEN players
      ELSE NULL
    END
  ) AS sr
FROM
  (
    SELECT
      teams.conference AS conference,
      players.year,
      COUNT(1) AS players
    FROM
      benn.college_football_players players
      JOIN benn.college_football_teams teams ON teams.school_name = players.school_name
    GROUP BY
      1,
      2
  ) sub
GROUP BY
  1
ORDER BY
  1
  
/*Technically, you've now accomplished the goal of this tutorial. But this could still be made a little better. 
You'll notice that the above query produces a list that is ordered alphabetically by Conference. 
It might make more sense to add a "total players" column and order by that (largest to smallest):*/
SELECT
  conference,
  SUM(players) AS total_players,
  SUM(
    CASE
      WHEN year = 'FR' THEN players
      ELSE NULL
    END
  ) AS fr,
  SUM(
    CASE
      WHEN year = 'SO' THEN players
      ELSE NULL
    END
  ) AS so,
  SUM(
    CASE
      WHEN year = 'JR' THEN players
      ELSE NULL
    END
  ) AS jr,
  SUM(
    CASE
      WHEN year = 'SR' THEN players
      ELSE NULL
    END
  ) AS sr
FROM
  (
    SELECT
      teams.conference AS conference,
      players.year,
      COUNT(1) AS players
    FROM
      benn.college_football_players players
      JOIN benn.college_football_teams teams ON teams.school_name = players.school_name
    GROUP BY
      1,
      2
  ) sub
GROUP BY
  1
ORDER BY
  2 DESC