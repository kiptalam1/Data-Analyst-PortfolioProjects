SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..DEATHS
ORDER BY 1, 2


--Looking at Total cases vs Total deaths
--shows likelihood of dying if you contract covid in your country
SELECT location, date, 
	total_cases,
	total_deaths, 
	cast(total_deaths AS int)/ cast(total_cases AS decimal) *100 AS 'Death Percentage'
FROM PortfolioProject..DEATHS
where location = 'Kenya'
ORDER BY 1, 2


--looking at Total cases vs Population
--Shows the percentage of population that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS 'Case Percentage'
FROM PortfolioProject..DEATHS
where location = 'Kenya'
ORDER BY 1, 2


--showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..DEATHS
where continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC

--CONTINENTS
--showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..DEATHS
where continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
--shows likelihood of dying if you contract covid in your continent
SELECT location, date, 
	total_cases,
	total_deaths, 
	cast(total_deaths AS int)/ cast(total_cases AS decimal) *100 AS 'Death Percentage'
FROM PortfolioProject..DEATHS
where continent is not null
ORDER BY 1, 2


--showing the likelihood of dying for the new cases
SELECT date, 
	SUM(new_cases) AS totalcases,
	SUM(new_deaths) AS totaldeaths, 
	SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..DEATHS
where continent is not null
GROUP BY date
ORDER BY 1, 2


--showing the likelihood of dying if you contract covid in the world
SELECT  
	SUM(new_cases) AS totalcases,
	SUM(new_deaths) AS totaldeaths, 
	SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..DEATHS
where continent is not null
ORDER BY 1, 2


--Lookoing at total population vs vaccinations
SELECT D.continent, D.location,D.date,d.population, V.new_vaccinations,
SUM(CONVERT(INT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM PortfolioProject..DEATHS as D
JOIN PortfolioProject..VACCINATIONS as V
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3



--USING CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT D.continent, D.location,D.date,d.population, V.new_vaccinations,
SUM(CONVERT(INT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM PortfolioProject..DEATHS as D
JOIN PortfolioProject..VACCINATIONS as V
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
--ORDER BY 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date DATETIME,
population numeric,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location,D.date,d.population, V.new_vaccinations,
SUM(CONVERT(INT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM PortfolioProject..DEATHS as D
JOIN PortfolioProject..VACCINATIONS as V
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated 
as
SELECT D.continent, D.location,D.date,d.population, V.new_vaccinations,
SUM(CONVERT(INT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) as RollingPeopleVaccinated
FROM PortfolioProject..DEATHS as D
JOIN PortfolioProject..VACCINATIONS as V
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
--ORDER BY 2,3


CREATE VIEW TotalDeathPercentage as --shows likelihood of dying if you contract covid in your continent
SELECT location, date, 
	total_cases,
	total_deaths, 
	cast(total_deaths AS int)/ cast(total_cases AS decimal) *100 AS 'Death Percentage'
FROM PortfolioProject..DEATHS
where continent is not null
--ORDER BY 1, 2


CREATE VIEW NewDeathPercentage
as
--showing the likelihood of dying for the new cases
SELECT date, 
	SUM(new_cases) AS totalcases,
	SUM(new_deaths) AS totaldeaths, 
	SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..DEATHS
where continent is not null
GROUP BY date
--ORDER BY 1, 2


CREATE VIEW WorldDeathPercentage
AS
--showing the likelihood of dying if you contract covid in the world
SELECT  
	SUM(new_cases) AS totalcases,
	SUM(new_deaths) AS totaldeaths, 
	SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..DEATHS
where continent is not null
--ORDER BY 1, 2
