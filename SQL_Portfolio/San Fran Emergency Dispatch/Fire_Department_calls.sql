/* https://github.com/DemetriousLloyd/Portfolio/blob/main/R_Py_Projects/San_Fran_Emergency_Dispatch/Emergency_Dispatch.ipynb

This is my Python EDA done in SQL

At the time I was having difficulty loading CSV files into PostGreSQL. SQL is the proper tool for this analysis

- CSV loaded as table "Fire_Department_Calls"

*/

-- Check duplicates
-- Corresponds to line 10 in the Python Jupyter Notebook


SELECT COUNT(*)
FROM "Fire_Department_Calls"
GROUP BY "Call Number", "Unit ID", "Incident Number"
HAVING COUNT(*) > 1
LIMIT 5;

-- 0 duplicates returned 

SELECT COUNT(*)
FROM "Fire_Department_Calls"
GROUP BY "Unit ID", "Incident Number"
HAVING COUNT(*) > 1
LIMIT 5;

-- 0 duplicates returned
SELECT COUNT(*)
FROM "Fire_Department_Calls"
GROUP BY "Unit ID", "Call Number"
HAVING COUNT(*) > 1
LIMIT 5;

-- 0 duplicates returned

SELECT COUNT(*)
FROM "Fire_Department_Calls"
GROUP BY "Call Number", "Incident Number"
HAVING COUNT(*) > 1
LIMIT 5;

-- Duplicates Exist on unique identifiers Call Number and Incident Number

-- Inspect this by creating a table of only the duplicate values

-- Corresponds to line 12 in the Python Jupyter Notebook
WITH dup_ids AS (
    SELECT "Call Number", "Incident Number", COUNT(*)
    FROM "Fire_Department_Calls"
    GROUP BY "Call Number", "Incident Number"
    HAVING COUNT(*) > 1
)
SELECT f.*
FROM "Fire_Department_Calls" AS f
INNER JOIN dup_ids AS d ON f."Call Number" = d."Call Number" AND f."Incident Number" = d."Incident Number"
ORDER BY f."Call Number", f."Incident Number"
LIMIT  5;

-- One Call Multiple Unit IDs and multiple Unit Types

-- Remove Duplicates
-- Focus on calls received timestamp and dispatch TIMESTAMP
    -- remove Unit ID and Unit Type from the Search criteria
WITH ranks AS (
SELECT 
-- partition duplicates by unique IDs "Call Number" and "Incident Number"
ROW_NUMBER() OVER (PARTITION BY "Call Number", "Incident Number") AS "RowNum",
"Call Number", 
"Incident Number", 
"Call Type", 
"Received DtTm", 
"Dispatch DtTm", 
"Call Final Disposition", 
"City", 
"Battalion", 
"Station Area", 
"Fire Prevention District", 
"Supervisor District", 
"Neighborhooods - Analysis Boundaries"
FROM "Fire_Department_Calls"
)
-- Windows function of RoW_Number used to select rows without unit type duplicates
SELECT 
"Call Number", 
"Incident Number", 
"Call Type", 
"Received DtTm", 
"Dispatch DtTm", 
"Call Final Disposition", 
"City", 
"Battalion", 
"Station Area", 
"Fire Prevention District", 
"Supervisor District", 
"Neighborhooods - Analysis Boundaries"
FROM ranks
-- Pull only the 1st level of all partitions to reomve duplicates on unique ids "Call Number" and "Incident Number"
WHERE "RowNum" = 1;
-- No duplicates above, only picks the first partition


-- Corresponds to line 23 in the Python Jupyter Notebook
-- Non duplicate EDA STATISTICS

WITH ranks AS (
SELECT 
ROW_NUMBER() OVER (PARTITION BY "Call Number", "Incident Number") AS "RowNum",
"Received DtTm", 
"Dispatch DtTm"
FROM "Fire_Department_Calls"
),
non_duplicates AS (
SELECT 
"Received DtTm", 
"Dispatch DtTm"
FROM ranks
WHERE "RowNum" = 1
),
-- Select difference in call time to dispatch in seconds using EPOCH
"seconds" AS (
SELECT EXTRACT(EPOCH FROM (CAST("Dispatch DtTm" AS TIMESTAMP) - CAST("Received DtTm" AS TIMESTAMP))) AS "Dispatch_Seconds"
FROM "non_duplicates"
)
-- Summary STATISTICS-- corresponds to line 23 in Jupyter Notebook
SELECT
COUNT("Dispatch_Seconds"),
ROUND(AVG("Dispatch_Seconds"), 2) AS AVG,
ROUND(STDDEV_SAMP("Dispatch_Seconds"), 2) AS STDEV,
MAX("Dispatch_Seconds"),
MIN("Dispatch_Seconds"),
percentile_cont(0.25) WITHIN GROUP (ORDER BY "Dispatch_Seconds") AS Q1,
percentile_cont(0.50) WITHIN GROUP (ORDER BY "Dispatch_Seconds") AS median, -- Median
percentile_cont(0.75) WITHIN GROUP (ORDER BY "Dispatch_Seconds") AS Q3,
ROUND(SUM("Dispatch_Seconds"), 2) AS SUM
FROM "seconds"
-- no negative times
WHERE "Dispatch_Seconds" > 0;


/* Repeat the CTE ABOVE With the correpsonding fields in a GROUP BY clause to get subsets

Fields: 'Call Type', 'Call Final Disposition', 'Battalion' were used in the Python Jupyter Notebook

*/

-- Call Type Grouping Example: Battalion Grouping

-- include battalion in CTEs for later grouping
WITH ranks AS (
SELECT 
ROW_NUMBER() OVER (PARTITION BY "Call Number", "Incident Number") AS "RowNum",
"Received DtTm", 
"Dispatch DtTm", 
"Battalion"
FROM "Fire_Department_Calls"
),
non_duplicates AS (
SELECT 
"Received DtTm", 
"Dispatch DtTm",
"Battalion"
FROM ranks
WHERE "RowNum" = 1
),
-- Select difference in call time to dispatch in seconds using EPOCH
"seconds" AS (
SELECT EXTRACT(EPOCH FROM (CAST("Dispatch DtTm" AS TIMESTAMP) - CAST("Received DtTm" AS TIMESTAMP))) AS "Dispatch_Seconds",
"Battalion"
FROM "non_duplicates"
)
-- Summary STATISTICS-- corresponds to line 23 in Jupyter Notebook
SELECT
"Battalion",
COUNT("Dispatch_Seconds"),
ROUND(AVG("Dispatch_Seconds"), 2) AS AVG,
ROUND(STDDEV_SAMP("Dispatch_Seconds"), 2) AS STDEV,
MAX("Dispatch_Seconds"),
MIN("Dispatch_Seconds"),
percentile_cont(0.25) WITHIN GROUP (ORDER BY "Dispatch_Seconds") AS Q1,
percentile_cont(0.50) WITHIN GROUP (ORDER BY "Dispatch_Seconds") AS median, -- Median
percentile_cont(0.75) WITHIN GROUP (ORDER BY "Dispatch_Seconds") AS Q3,
ROUND(SUM("Dispatch_Seconds"), 2) AS SUM
FROM "seconds"
-- no negative times
WHERE "Dispatch_Seconds" > 0
-- group by Battalion
GROUP BY "Battalion";