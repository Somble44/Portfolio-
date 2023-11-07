SELECT LOCATION, date,total_cases, new_cases,total_deaths,population
FROM CovidDeaths	
ORDER BY 1,3

--total cases v deaths 
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM CovidDeaths
ORDER BY Deathpercentage desc 


-- total cases v population 
SELECT location,date,total_cases,population, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths
ORDER BY CasePercentage DESC

-- Highest infection rate by population 
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX (total_cases/population)*100 AS InfectionRate 
FROM CovidDeaths
GROUP BY location,population
ORDER BY InfectionRate DESC 

-- death count per population 
SELECT location, MAX(cast(total_deaths AS int)) AS  DeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY DeathCount DESC 

--Continent breakdown
SELECT continent, MAX(cast(total_deaths AS int)) AS  DeathCount
FROM CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY DeathCount DESC 

-- Global summations 

SELECT date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths
FROM CovidDeaths
WHERE continent is not null 
GROUP BY date


-- JOINS 

SELECT da.continent,da.location,da.date,da.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by da.location ORDER BY da.location,da.date) AS total_vacinated 
FROM CovidDeaths da
join Covidvaciene vac 
  ON da.date = vac.date
  AND da.location = vac.location
WHERE da.continent is not null 
ORDER BY 2,3


-- CTE
WITH popvac (continent,locatio,date ,population,vaccinations, total_vacinated) 
AS (
SELECT da.continent,da.location,da.date,da.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by da.location ORDER BY da.location,da.date) AS total_vacinated 
FROM CovidDeaths da
join Covidvaciene vac 
  ON da.date = vac.date
  AND da.location = vac.location
WHERE da.continent is not null 
--ORDER BY 2,3
)

SELECT * ,(total_vacinated/population)*100 as percentagevac
FROM popvac




--temp table 
DROP TABLE IF Exists #temptableVac
CREATE TABLE #temptableVac
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric ,
new_vaccinations numeric,
total_vacinated numeric
) 
INSERT INTO #temptableVac
SELECT da.continent,da.location,da.date,da.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by da.location ORDER BY da.location,da.date) AS total_vacinated 
FROM CovidDeaths da
join Covidvaciene vac 
  ON da.date = vac.date
  AND da.location = vac.location
WHERE da.continent is not null 
--ORDER BY 2,3

SELECT * ,(total_vacinated/population)*100 as percentagevac
FROM #temptableVac
ORDER BY 2,3

-- view 


CREATE VIEW vacview AS 
SELECT da.continent,da.location,da.date,da.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (partition by da.location ORDER BY da.location,da.date) AS total_vacinated 
FROM coviddeaths da
join Covidvaciene vac 
  ON da.date = vac.date
  AND da.location = vac.location
WHERE da.continent is not null 
--ORDER BY 2,3

SELECT *
FROM vacview