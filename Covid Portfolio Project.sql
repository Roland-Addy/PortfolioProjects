USE PortfolioProject

SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Selected Data that is going to be used:

SELECT location, date,total_cases,new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
--In Canada
--Showing the likelihood of death when infected
SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
order by 2

--In Ghana
--Showing the likelihood of death when infected
SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ghana'
order by 2

--In the US
--Showing the likelihood of death when infected
SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
order by 2

-- Looking at Total Cases vs Population
--In Canada
SELECT location, date,total_cases,population,(total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
order by 2


-- Looking at Total Cases vs Population
--In Ghana
SELECT location, date,total_cases,population,(total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Ghana'
order by 2

--Highest infection rate compared to the population for all countries (within the past year)
SELECT location,population,MAX(total_cases) as MaxNumCases,MAX((total_cases/population))*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
order by InfectionRate DESC

--Showing Countries with Highest Death Count per Population
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC

--Let's break things down by continent
--Showing continents with the highest death counts
SELECT continent,SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS 
SELECT date,SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

--TOTAL ACROSS THE WORLD
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

--JOINING BOTH TABLES
SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

--LOOKING AT THE TOTAL POPULATIONS VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1, 2, 3

--LOOKING AT ROLLING VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


--USING COMMON TABLE EXPRESSIONS (CTE)
--Looking at the percentage of people vaccinated with at least one dose
WITH population_vs_vaccinations (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 FROM population_vs_vaccinations
WHERE Location = 'Ghana'

--TEMP TABLE
 DROP TABLE IF EXISTS #percentpopulationvaccinated

 CREATE TABLE #percentpopulationvaccinated (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #percentpopulationvaccinated 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM #percentpopulationvaccinated 
WHERE Location = 'Ghana'

-- Creatings Views to Store Data for Later Visualizations:

CREATE VIEW 
percentpopulationvaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

DROP VIEW percentpopulationvaccinated