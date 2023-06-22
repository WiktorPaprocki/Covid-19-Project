SELECT * 
FROM CovidDeaths;

SELECT * 
FROM CovidVaccinations
ORDER BY location, date;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location;

-- Likelihood of dying if you got infected by covid in USA
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE location = 'United States' AND total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 1;

-- Percentage of population got Covid in Poland
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage_of_infected_population
FROM CovidDeaths
WHERE location = 'Poland' AND total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY location;

-- Countries with highiest infection rate compared to population
SELECT location, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population))*100 AS Percentage_of_infected_population
FROM CovidDeaths
GROUP BY location
ORDER BY Percentage_of_infected_population DESC;

-- Countries with highiest death count
SELECT location, MAX(cast(total_deaths as int)) AS Total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC;

-- Continents with highest death count
SELECT location, MAX(cast(total_deaths as int)) AS Total_death_count
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_death_count DESC;

-- Population vs vaccinations ----------------------------------------------------
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_vaccinated
FROM CovidDeaths AS dea 
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
ORDER BY 2, 3

--CTE
WITH PopvsVac AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_vaccinated
FROM CovidDeaths AS dea 
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL AND population IS NOT NULL
)

SELECT *, (People_vaccinated/population)*100 AS Percentage_of_population_vaccinated
FROM PopvsVac
---------------------------------------------------------------------------------

-- Creating view to store data for later visualization
CREATE VIEW Percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_vaccinated
FROM CovidDeaths AS dea 
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL AND population IS NOT NULL

SELECT * FROM Percent_population_vaccinated