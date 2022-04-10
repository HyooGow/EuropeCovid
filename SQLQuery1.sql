-- Select data I am going to use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM DeathsCovid
WHERE continent IS NOT NULL and continent = 'Europe'
ORDER BY Location, date ASC

-- Total cases versus Total Deaths
-- Likelihood of dying if contracting covid per country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM DeathsCovid
WHERE continent IS NOT NULL and continent = 'Europe'
ORDER BY Location, date ASC

-- Total cases versus Population
-- Percentage of population contracted covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM DeathsCovid
WHERE continent IS NOT NULL and continent = 'Europe'
ORDER BY Location, date ASC

-- Looking at countries with highest infection rate compared to population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM DeathsCovid
WHERE continent IS NOT NULL and continent = 'Europe'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at countries with highest death count compared to population
-- Total_Deaths is datatype nvarchar, converted to integer
SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM DeathsCovid
WHERE continent IS NOT NULL and continent = 'Europe'
GROUP BY Location, population
ORDER BY TotalDeathCount DESC

-- Numbers across Europe, total
-- new_deaths is data type float, converted to interger
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From DeathsCovid
WHERE continent IS NOT NULL and continent = 'Europe'

-- Europe population vs vaccinations
-- New_vaccinations wrong data type, converted to interger
-- Partitioned by location as we want the count to restart when it hits a new location
-- Need to order the partition by location AND by date  otherwise the rolling won't work
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(cast(V.new_vaccinations as INT)) 
OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/d.population)*100
FROM DeathsCovid D
JOIN VacinationsCovid V
ON D.location = V.location
AND d.date = V.date
WHERE D.continent IS NOT NULL and D.continent = 'Europe'
ORDER BY D.location, D.date


-- Created CTE for RollingPeopleVaccinated
-- Ensure number of columns in CTE match the query
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(cast(V.new_vaccinations as INT)) 
OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS RollingPeopleVaccinated
FROM DeathsCovid D
JOIN VacinationsCovid V
ON D.location = V.location
AND d.date = V.date
WHERE D.continent IS NOT NULL and D.continent = 'Europe'
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

