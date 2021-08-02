SELECT *
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [MSG-Covid-19]..CovidVaccinations
--WHERE continent is not null
--ORDER BY 3,4

-- Selecting the location, date, total_cases, new_cases, total_deaths, population columns
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is not null
ORDER BY location, date

-- Comparing total deaths and total cases, adding a deaths to cases ratio (percentage) column 
SELECT location, date, total_cases, total_deaths, (100* total_deaths / total_cases) AS deaths_to_cases_ratio
FROM [MSG-Covid-19]..CovidDeaths
WHERE location LIKE 'Turkey' and continent is not null
ORDER BY date

-- Adding a cases to total population ratio (percentage) column 
SELECT location, date, total_cases, population, (100* total_cases / population) AS cases_to_population_ratio
FROM [MSG-Covid-19]..CovidDeaths
WHERE location LIKE 'Turkey' and continent is not null
ORDER BY date

-- Display countries with the highest cases to total population ratios
SELECT location, population, MAX(total_cases) AS max_no_of_cases, MAX((100* total_cases / population)) AS cases_to_population_ratio
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY cases_to_population_ratio DESC

-- Display countries with the highest death count
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS max_no_of_deaths
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY max_no_of_deaths DESC

-- Display countries with the highest death count to total population ratios
SELECT location, MAX(CAST(total_deaths AS INT)) AS max_no_of_deaths, MAX((100* total_deaths / population)) AS deaths_to_population_ratio
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY deaths_to_population_ratio DESC

-- Display the leading country from each continent with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS max_no_of_deaths_from_single_country, MAX((100* total_deaths / population)) AS deaths_to_population_ratio
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY max_no_of_deaths_from_single_country DESC

-- Display each continent's total death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS max_no_of_deaths, MAX((100* total_deaths / population)) AS deaths_to_population_ratio
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is null and location not like '%World%'
GROUP BY location
ORDER BY max_no_of_deaths DESC

-- Global Totals for total_cases and total_deaths for each distinct date
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deaths_to_cases_ratio
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Global Totals for total_cases and total_deaths
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deaths_to_cases_ratio
FROM [MSG-Covid-19]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Comparing Population and Vaccination Records using Joins
SELECT *
FROM [MSG-Covid-19]..CovidDeaths dth
JOIN [MSG-Covid-19]..CovidVaccinations vac
	ON dth.location = vac.location
	and dth.date = vac.date

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
FROM [MSG-Covid-19]..CovidDeaths dth
JOIN [MSG-Covid-19]..CovidVaccinations vac
	ON dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
ORDER BY 2,3

-- Using CTE to store temporary results; calculate running totals for vaccinations and the percentage of the population vaccinated
WITH Running_Totals_Vac(continent, location, date, population, new_vaccinations, cumulative_sum_of_vaccinations)
AS (
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date)
	as cumulative_sum_of_vaccinations
FROM [MSG-Covid-19]..CovidDeaths dth
JOIN [MSG-Covid-19]..CovidVaccinations vac
	ON dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
)
SELECT *, 100*(cumulative_sum_of_vaccinations/population) as population_vaccination_ratio
FROM Running_Totals_Vac


-- Using Temp Tables to store temporary results; calculate running totals for vaccinations and the percentage of the population vaccinated
DROP TABLE IF exists #CovidPopulationVaccinations
CREATE TABLE #CovidPopulationVaccinations(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_sum_of_vaccinations numeric)

INSERT INTO #CovidPopulationVaccinations
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date)
	as cumulative_sum_of_vaccinations
FROM [MSG-Covid-19]..CovidDeaths dth
JOIN [MSG-Covid-19]..CovidVaccinations vac
	ON dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null

SELECT *, 100*(cumulative_sum_of_vaccinations/population) as population_vaccination_ratio
FROM #CovidPopulationVaccinations

-- Creating a view to be used later in visualizations
DROP VIEW IF exists CovidPopulationVaccinationsView;
GO

CREATE VIEW CovidPopulationVaccinationsView AS
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location, dth.date)
	as cumulative_sum_of_vaccinations
FROM [MSG-Covid-19]..CovidDeaths dth
JOIN [MSG-Covid-19]..CovidVaccinations vac
	ON dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null

SELECT *
FROM CovidPopulationVaccinationsView