-- 1. Explore Covid in Egypt
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    new_deaths,
    population
FROM 
    CovidDeaths
WHERE 
    location LIKE '%Egypt%'
ORDER BY 
    location,
    date;

-- 2. What is the death rate across different locations?
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    CONCAT(ROUND((total_deaths / total_cases), 3) * 100, '', '%') AS DeathRate
FROM 
    CovidDeaths
ORDER BY 
    location,
    date;

-- 3. Get the location with the highest death rate.
SELECT 
    *
FROM 
    (
        SELECT 
            location,
            AVG(total_deaths / total_cases) * 100 AS DeathRate,
            ROW_NUMBER() OVER (ORDER BY AVG(total_deaths / total_cases) DESC) AS RowNumber
        FROM 
            CovidDeaths
        GROUP BY 
            location
    ) AS x
WHERE 
    x.RowNumber = 1;

-- 4. What is Egypt's rank in terms of death rate?
SELECT 
    *
FROM 
    (
        SELECT 
            location,
            AVG(total_deaths / total_cases) AS DeathRate,
            ROW_NUMBER() OVER (ORDER BY AVG(total_deaths / total_cases) DESC) AS RowNum
        FROM 
            CovidDeaths
        GROUP BY 
            location
    ) AS RankedLocations
WHERE 
    location LIKE '%Egypt%';

-- 5. Which location has the highest total cases?
SELECT 
    *
FROM 
    (
        SELECT 
            location,
            SUM(total_cases) AS TotalCase,
            RANK() OVER (ORDER BY SUM(total_cases) DESC) AS Rank_Total_Case
        FROM 
            CovidDeaths
        GROUP BY 
            location
        HAVING 
            location NOT IN ('World', 'Europe', 'North America', 'Asia')
    ) AS TotalCase
WHERE 
    Rank_Total_Case = 1;

-- 6. Show the percentage of population that got Covid through each date.
SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS Density
FROM 
    CovidDeaths
ORDER BY  
    location,
    date;

-- 7. Explore the total case vs population and show the percentage of population that got Covid.
SELECT 
    location,
    ROUND(AVG(total_cases), 0) AS total_cases,
    ROUND(AVG(population), 0) AS population,
    ROUND(AVG(total_cases / population) * 100, 3) AS CaseDensity
FROM 
    CovidDeaths
GROUP BY 
    location
ORDER BY 
    CaseDensity DESC;

-- 8. Show the location with the highest death count per population.
WITH HightestDeath AS (
    SELECT 
        location,
        SUM(total_deaths) AS TotalDeath,
        RANK() OVER (ORDER BY SUM(total_deaths) DESC) AS Ranks
    FROM 
        CovidDeaths
    GROUP BY 
        location
)
SELECT *
FROM 
    HightestDeath
WHERE 
    location LIKE '%Egypt%';

-- 9. Show the country with the highest return rate.
-- (This question seems incomplete, please provide more context if needed)

-- 10. Show the darkest day in each country.
WITH DarkDay AS (
    SELECT 
        location,
        new_deaths,
        CAST(date AS DATE) AS Date,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY new_deaths DESC) AS Ranks
    FROM 
        CovidDeaths
    WHERE 
        new_deaths IS NOT NULL
)
SELECT *
FROM 
    DarkDay
WHERE 
    Ranks = 1
ORDER BY 
    new_deaths DESC;

-- 11. Show the continent with the highest total deaths.
SELECT 
    continent,
    SUM(total_deaths) AS TotalDeath,
    RANK() OVER (ORDER BY SUM(total_deaths) DESC) AS Ranks
FROM 
    CovidDeaths
GROUP BY 
    continent
HAVING 
    continent IS NOT NULL;

-- 12. Show the dark day in the world.
SELECT 
    CAST(date AS DATE) AS Date,
    SUM(total_deaths) AS [Total Death], 
    ROW_NUMBER() OVER (ORDER BY SUM(total_deaths) DESC) AS Ranks
FROM 
    CovidDeaths
GROUP BY 
    date;

-- 13. Show the day that has the maximum cases.
WITH MaxCase AS ( 
    SELECT 
        location,
        CAST(date AS DATE) AS Date, 
        MAX(total_cases) AS [Total Case], 
        ROW_NUMBER() OVER (PARTITION BY date ORDER BY SUM(total_cases) DESC) AS Ranks
    FROM 
        CovidDeaths
    WHERE 
        total_deaths IS NOT NULL
    GROUP BY 
        date, 
        location
)
SELECT *
FROM 
    MaxCase
WHERE 
    Ranks = 1;

-- 14. Show the country that has the maximum deaths on each day.
WITH [Country Death] AS (
    SELECT  
        location,
        CAST(date AS DATE) AS Date,
        MAX(total_deaths) AS Deaths,
        ROW_NUMBER() OVER (PARTITION BY date ORDER BY MAX(total_deaths) DESC) AS Ranks
    FROM 
        CovidDeaths
    WHERE 
        total_deaths IS NOT NULL
    GROUP BY 
        location,
        date
)
SELECT *
FROM 
    [Country Death]
WHERE 
    Ranks = 1;

-- 15. Show the country that has the maximum recovery rate from Covid.
SELECT 
    location,
    SUM(total_deaths) AS total_deaths, 
    SUM(total_cases) AS total_cases, 
    (SUM(total_deaths) / SUM(total_cases)) * 100 AS [Recovery Ratio]
FROM 
    CovidDeaths
WHERE 
    total_cases IS NOT NULL
    AND 
    total_deaths IS NOT NULL
    AND 
    location IS NOT NULL
    AND 
    continent IS NOT NULL
GROUP BY 
    location;

-- 16. Show the country that has the maximum recovery ratio in each continent.
WITH Recovery_ratio AS (
    SELECT 
        continent,
        location,
        (SUM(total_deaths) / SUM(total_cases)) * 100 AS [Recovery Ratio],
        ROW_NUMBER() OVER (PARTITION BY continent ORDER BY SUM(total_deaths) / SUM(total_cases) DESC) AS Rn
    FROM 
        CovidDeaths
    GROUP BY 
        continent,
        location
    HAVING 
        continent IS NOT NULL
        AND 
        (SUM(total_deaths) / SUM(total_cases)) IS NOT NULL
) 
SELECT
    * 
FROM 
    Recovery_ratio
WHERE 
    Rn = 1
ORDER BY 
    continent;

-- 17. Show the total population vs vaccinations.
SELECT   
    dea.location,
    MAX(dea.population) AS population,
    SUM(vac.new_tests) AS new_tests
FROM 
    CovidVaccinations vac 
JOIN 
    CovidDeaths dea
ON 
    vac.date = dea.date
    AND
    vac.location = dea.location
where
	vac.total_tests is not null
	 
group by dea.location


 
 -- 18 Sum new_vaccinations in each continent 

select 
	continent , 
	location ,
	date 
 	,new_vaccinations
	,sum(new_vaccinations)over (partition by location order by location , date)totalVaccination
	
 from 
	CovidVaccinations
where continent is not null and location is not null