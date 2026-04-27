/*
Covid-19 Data Exploration Project
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

USE protfolio_project;
SELECT COUNT(*) FROM coviddeaths;

-- 1. Initial Data Check
-- Inspecting the raw data to ensure correct import
Select 
	*
From coviddeaths
Where continent is not null 
  and continent <> ''
order by 3,4;


-- 2. Select Data that we are going to be starting with
-- Getting a baseline of the essential metrics
Select 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
From coviddeaths
Where continent is not null 
  and continent <> ''
order by 1,2;


-- 3. Total Cases vs Total Deaths
-- Calculates the likelihood of dying if you contract covid in a specific country
Select 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
Where location = "United States"
  and continent is not null 
  and continent <> ''
order by 1,2;


-- 4. Total Cases vs Population
-- Shows what percentage of the population was infected with Covid
Select 
	Location, 
	date, 
	Population, 
	total_cases, 
	(total_cases/population)*100 as PercentPopulationInfected
From coviddeaths
Where continent is not null 
  and continent <> ''
order by 1,2;


-- 5. Countries with Highest Infection Rate compared to Population
-- Identifying which countries had the highest density of infections
Select 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount, 
	Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
Where continent is not null 
  and continent <> ''
Group by Location, Population
order by PercentPopulationInfected desc;


-- 6. Countries with Highest Death Count per Population
-- Measuring total impact in terms of mortality
Select 
	Location, 
	MAX(total_deaths) as TotalDeathCount
From coviddeaths
Where continent is not null 
  and continent <> ''
Group by Location
order by TotalDeathCount desc;



-- 7. BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
Select 
	continent, 
	MAX(total_deaths) as TotalDeathCount
From coviddeaths
Where continent is not null 
  and continent <> ''
Group by continent
order by TotalDeathCount desc;


-- 8. GLOBAL NUMBERS
-- Aggregating total cases and deaths globally to get the overall world percentage
Select 
	SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths,
	SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From coviddeaths
where continent is not null 
order by 1,2;



-- 9. Total Population vs Vaccinations
-- Joining Deaths and Vaccinations tables to see daily vaccination activity
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations
From coviddeaths dea
Join covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
  and dea.continent <> ''
order by 1,2 ;



-- 10. Rolling Vaccination Totals
-- Using a Window Function to calculate a running sum of vaccinations per country
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
    sum(cast(coalesce(vac.new_vaccinations, 0) as unsigned))
		over (partition by dea.location 
			order by dea.location, dea.date) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
  and dea.continent <> ''
order by 2,3 ;



-- 11. Using CTE (Common Table Expression) 
-- Allows us to perform calculations on the 'RollingPeopleVaccinated' column created in the previous step
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
    sum(cast(coalesce(vac.new_vaccinations, 0) as unsigned))
		over (partition by dea.location 
			order by dea.location, dea.date) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
  and dea.continent <> ''
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated_percent
From PopvsVac;



-- 12. Temp Table Approach
-- Storing results in a temporary table for more complex multi-step querying
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
Create Temporary Table PercentPopulationVaccinated
(
	Continent varchar(255),
	Location varchar(255),
	Date datetime,
	Population bigint,
	New_vaccinations bigint,
	RollingPeopleVaccinated bigint
);

insert into PercentPopulationVaccinated
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
    sum(cast(coalesce(vac.new_vaccinations, 0) as unsigned))
		over (partition by dea.location 
			order by dea.location, dea.date) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
  and dea.continent <> '';

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated_percent
From PercentPopulationVaccinated;



-- 13. Creating View for Visualization
-- Creating a permanent view to store data for Power BI or Tableau dashboards
-- Create View PercentPopulationVaccinatedBYcontinent as
-- Select 
-- 	MainQuery.continent, 
-- 	SUM(MainQuery.CountryPop) as Total_Continent_Population, 
-- 	SUM(MainQuery.CountryVac) as Total_Continent_Vaccinations,
--     (SUM(MainQuery.CountryVac) / SUM(MainQuery.CountryPop)) * 100 AS Vac_Percentage
-- From (
-- 	Select 
-- 		dea.continent, 
-- 		dea.location, 
-- 		MAX(dea.population) as CountryPop, 
-- 		SUM(CAST(coalesce(vac.new_vaccinations, 0) AS UNSIGNED)) as CountryVac
-- 	From coviddeaths dea
-- 	Join covidvac vac
-- 		On dea.location = vac.location
-- 		and dea.date = vac.date
-- 	Where dea.continent is not null 
-- 	  and dea.continent <> ''
-- 	Group by dea.continent, dea.location
-- ) as MainQuery
-- Group by MainQuery.continent
-- -- Order by 1, 2;

-- Testing the View
select * from PercentPopulationVaccinatedBYcontinent;

SELECT COUNT(*) FROM CovidDeaths;