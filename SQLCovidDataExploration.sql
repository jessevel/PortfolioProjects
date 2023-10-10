SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--Select Data to be used

SELECT location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL


-- Total Cases vs. Total Deaths

SELECT location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got Covid

SELECT location,
	date,
	total_cases,
	population,
	(total_cases/population)*100 AS case_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%states%'
ORDER BY 1, 2


-- Looking at Countries with highest infection rate compared to population
SELECT location,
	population,
	MAX(total_cases) AS total_cases,
	MAX((total_cases/population))*100 AS person_infected_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY person_infected_percentage DESC


-- Showing the countries with highest death count per population

SELECT location,
	MAX(cast(total_deaths AS INT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
--WHERE location like '%states%'
GROUP BY location
ORDER BY total_deaths DESC

-- Showing the highest death count by continent

SELECT continent
	MAX(cast(total_deaths AS INT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%states%'
GROUP BY continent
ORDER BY total_deaths DESC



--Global Numbers

SELECT date,
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage--(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%states%'
GROUP BY date
ORDER BY 1, 2

-- total cases vs. total deaths
SELECT SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage--(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%states%'
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs. Vaccinations

SELECT dea.continent,
	dea.location,
	dea.date,
	dea. population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated,
	(RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,
	dea.location,
	dea.date,
	dea. population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac 



-- temp table
DROP TABLE if exists  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent,
	dea.location,
	dea.date,
	dea. population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM  #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,
	dea.location,
	dea.date,
	dea. population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea. location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
