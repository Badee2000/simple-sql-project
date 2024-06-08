
-- Select Data that we are going to be using.
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2

-- Total Cases VS Total Deaths
-- Shows likelihood of dying if you become infected with covid in your country.
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Location like 'Roma%'
ORDER BY 1,2

-- Total Cases VS Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (CAST(total_cases AS float) / CAST(population AS float) * 100) AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
WHERE Location like '%states'
ORDER BY 1,2


-- Countries with the highest infection rate compared to population.
SELECT Location, population,
    MAX(total_cases) AS HighestInfectionCount,
    (MAX(total_cases) / population) * 100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with the highest death count per population.
SELECT Location, population,
MAX(CAST(total_deaths AS INT)) AS HighestDeathCount,
(MAX(CAST(total_deaths AS INT)) / population) * 100 AS PercentPopulationDead
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationDead DESC

-- Countries with the highest death count.
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeaths DESC


-- Continents with the highest death count.
SELECT Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeaths
FROM CovidProject..CovidDeaths
Where continent is not null
GROUP BY Continent
ORDER BY TotalDeaths DESC

-- Total Population VS Vaccinations for each day.
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS float)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as SumOfVacForEachDay
FROM CovidProject..CovidDeaths cd
JOIN CovidProject..CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2,3

-- Total Population VS Total Vaccinations.
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS float)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as SumOfVacAfterEachDay
FROM CovidProject..CovidDeaths cd
JOIN CovidProject..CovidVaccinations cv
ON cd.location = cv.location
and cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2,3

-- USE CTE
WITH PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS float)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date)
AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths cd
JOIN CovidProject..CovidVaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 2,3
)

Select *,(RollingPeopleVaccinated/population)*100 from PopVsVac

---- TEST
--SELECT cd.location, cd.population, cd.date, cv.people_vaccinated
--FROM CovidProject..CovidDeaths cd
--JOIN CovidProject..CovidVaccinations cv
--ON cd.location = cv.location
--and cd.date = cv.date
--WHERE cd.continent is not null
--ORDER BY 1,2,3
---- AFG:19151369
---- AFG:9066437