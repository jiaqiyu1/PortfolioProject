SELECT *
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT *
FROM [dbo].[CovidVaccinations]
WHERE continent IS NOT NULL
ORDER BY 3,4

-- retrive all necessary information
SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population

FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Cases vs Total Deaths 
  -- likehood of dying if you got covid in the selected country 
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage

FROM PortfolioProject..CovidDeaths
WHERE location ='China' AND continent IS NOT NULL
ORDER BY date DESC, DeathPercentage DESC


--Total Cases vs Population
SELECT 
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS PercentagePopulationInfected

FROM PortfolioProject..CovidDeaths
WHERE location ='China'AND continent IS NOT NULL
ORDER BY date DESC, PercentagePopulationInfected DESC


--Countries with the highest infection rate compared to population 

SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(total_cases/population)*100 AS PercentagePopulationInfected

FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


-- Countries with highest deaths count per population 
SELECT 
	location,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Break things down into Continent 
SELECT 
	continent,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Continents  with highest deaths count per population 
SELECT 
	continent,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Globally numbers
SELECT 
	--date,
	SUM(new_cases) AS TotalCases,
	SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage

FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY  DeathPercentage DESC


-- Total Population vs Vaccinations
WITH PopvsVac AS
(SELECT 
	Deaths.continent,
	Deaths.location,
	Deaths.date,
	Deaths.population,
	Vacc.new_vaccinations,
    SUM(CONVERT(BIGINT, Vacc.new_vaccinations)) 
				OVER (PARTITION BY Deaths.location 
						ORDER BY Deaths.location, Deaths.date
		) AS RollingPeopleVaccinated
	-- convert varchar to bigint(over the limlit of int)
FROM [dbo].[CovidDeaths] Deaths
LEFT JOIN [dbo].[CovidVaccinations] Vacc
	ON Deaths.location = Vacc.location
		AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL

)

SELECT *,
(RollingPeopleVaccinated/population)*100 AS VaccinatedRate
FROM PopvsVac


-- Solution2 with Temp Table
DROP TABLE IF EXISTS #PopvsVac2

SELECT 
	Deaths.continent,
	Deaths.location,
	Deaths.date,
	Deaths.population,
	Vacc.new_vaccinations,
    SUM(CONVERT(BIGINT, Vacc.new_vaccinations)) 
				OVER (PARTITION BY Deaths.location 
						ORDER BY Deaths.location, Deaths.date
		) AS RollingPeopleVaccinated
	-- convert varchar to bigint(over the limlit of int)

INTO #PopvsVac2

FROM [dbo].[CovidDeaths] Deaths
LEFT JOIN [dbo].[CovidVaccinations] Vacc
	ON Deaths.location = Vacc.location
		AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL


SELECT *,
(RollingPeopleVaccinated/population)*100 AS VaccinatedRate
FROM #PopvsVac2



-- View to store data for later visualisations

CREATE VIEW PercentPopulationVaccination AS

SELECT 
	Deaths.continent,
	Deaths.location,
	Deaths.date,
	Deaths.population,
	Vacc.new_vaccinations,
    SUM(CONVERT(BIGINT, Vacc.new_vaccinations)) 
				OVER (PARTITION BY Deaths.location 
						ORDER BY Deaths.location, Deaths.date
		) AS RollingPeopleVaccinated
	-- convert varchar to bigint(over the limlit of int)
FROM [dbo].[CovidDeaths] Deaths
LEFT JOIN [dbo].[CovidVaccinations] Vacc
	ON Deaths.location = Vacc.location
		AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL


