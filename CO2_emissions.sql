-- Taking a look of the dataset
SELECT *
FROM ['Carbon Dioxide Emission Estimat$'];

-- Checking if any columns have null values
SELECT 
[CO2 emission estimates] AS Country,
Year,
Series,
COUNT(*) AS total_rows,
SUM(CASE WHEN 'CO2 emission estimates' IS NULL THEN 1 ELSE 0 END) AS country_nulls,
SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
SUM(CASE WHEN Series IS NULL THEN 1 ELSE 0 END) AS series_nulls,
SUM(CASE WHEN Value IS NULL THEN 1 ELSE 0 END) AS value_nulls
FROM ['Carbon Dioxide Emission Estimat$']
GROUP BY Year, Series;
-- No columns contain any null values.

-- 1: Is there a trend of increasing carbon emission by each decade?
SELECT 
FLOOR(Year/10) * 10 AS decade, 
AVG(Value) AS avg_emission
FROM ['Carbon Dioxide Emission Estimat$']
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)'
GROUP BY FLOOR(Year/10)
ORDER BY decade;
-- There is a clear trend. Average emissions almost doubled between 1970s and 2010s.

-- 2: Top 10 countries with most amount of emissions
SELECT TOP 10 [CO2 emission estimates] AS Country, SUM(Value) AS Total_Emissions
FROM ['Carbon Dioxide Emission Estimat$']
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)'
GROUP BY [CO2 emission estimates]
ORDER BY Total_Emissions DESC;
-- Top 3 being China, US and India

-- 3: Top 10 countries with least amount of emissions
SELECT TOP 10 [CO2 emission estimates] AS Country, SUM(Value) AS Total_Emissions
FROM ['Carbon Dioxide Emission Estimat$']
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)'
GROUP BY [CO2 emission estimates]
ORDER BY Total_Emissions;
-- All of the countries are from South Africa

-- 4: Country with highest increase/decrease in CO2 emissions
WITH EmissionsByYear AS (
SELECT [CO2 emission estimates] AS Country, Year, SUM(Value) AS Total_Emissions
FROM ['Carbon Dioxide Emission Estimat$']
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)'
GROUP BY [CO2 emission estimates], Year
),
EarliestYear AS (
SELECT Country, Year AS Earliest_Year, Total_Emissions AS Earliest_Emissions
FROM EmissionsByYear
WHERE Year = (SELECT MIN(Year) FROM EmissionsByYear)
),
LatestYear AS (
SELECT Country, Year AS Latest_Year, Total_Emissions AS Latest_Emissions
FROM EmissionsByYear
WHERE Year = (SELECT MAX(Year) FROM EmissionsByYear)
),
EmissionsDifference AS (
SELECT e.Country, l.Latest_Emissions - e.Earliest_Emissions AS Emissions_Increase
FROM EarliestYear e
JOIN LatestYear l
ON e.Country = l.Country
)

SELECT Country, Emissions_Increase
FROM EmissionsDifference
ORDER BY Emissions_Increase DESC; -- Use ASC for the lowest increase
-- Countries with highest CO2 emission increase include China, India, Republic of Korea and Saudi Arabia
-- Countries with highest CO2 emission decrease include Germany, UK, France and Romania

-- 5: Global growth rate of emissions over time
WITH GlobalEmissions AS (
SELECT Year, SUM(Value) AS Total_Emissions
FROM ['Carbon Dioxide Emission Estimat$']
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)'
GROUP BY Year
)
SELECT Year, Total_Emissions,
(Total_Emissions - LAG(Total_Emissions) OVER (ORDER BY Year)) / LAG(Total_Emissions) OVER (ORDER BY Year) * 100 AS Growth_Rate
FROM GlobalEmissions
ORDER BY Year;
-- Most growth in CO2 emissions occurred between 1985 and 2005. After that, the growth has slowed down globally.