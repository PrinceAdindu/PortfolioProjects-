

  Select Location, date, total_cases, new_cases, total_deaths, population
  from [Portfolio Project]..[CovidDeaths]
  where continent IS NOT NULL
  Order by 1,2

  ---Looking at Total Cases vs Total Deaths
  -- Shows the likelihood of dying from contracting Covid in your country

   Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
  from [Portfolio Project]..[CovidDeaths]
  where location = 'Nigeria' and continent IS NOT NULL
  Order by 1,2

  -- Looking at Total Cases vs Population

   Select Location, date, Population, total_cases, (total_cases/Population)*100 AS PercentPopulationInfected
  from [Portfolio Project]..[CovidDeaths]
  where continent IS NOT NULL
  Order by 1,2

  --Looking at Countries with Highest Infection Rate compared to Population

  Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
  from [Portfolio Project]..[CovidDeaths]
  where continent IS NOT NULL
  Group by Location, Population
  Order by PercentPopulationInfected DESC

  --Showing Countries with the Highest Death Count Per Population

  Select Location, MAX(cast (total_deaths as int)) AS TotalDeathCount
  from [Portfolio Project]..[CovidDeaths]
  where continent IS NOT NULL
  Group by Location
  Order by TotalDeathCount DESC

  --Showing Continents with the Highest Death Count Per Population

  Select Continent, MAX(cast (total_deaths as int)) AS TotalDeathCount
  from [Portfolio Project]..[CovidDeaths]
  where continent IS NOT NULL
  Group by Continent
  Order by TotalDeathCount DESC

  -- GLOBAL INSIGHTS FROM THE COVID DATASET

  --This query outputs the details for the deathpercentage PER DAY

  Select date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
  from [Portfolio Project]..[CovidDeaths]
  where continent IS NOT NULL
  Group by date
  Order by 1,2

  --This query outputs the details for the deathpercentage ALL TOGETHER TILL DATE

   Select SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
  from [Portfolio Project]..[CovidDeaths]
  where continent IS NOT NULL
  Order by 1,2

  --Looking at Total Population Vs Vaccination

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  from [Portfolio Project]..[CovidDeaths] dea
  join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
  Order by 2,3

  -- To Calculate the Rolling Number of People Vaccinated

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
  AS RollingPeopleVaccinated
  from [Portfolio Project]..[CovidDeaths] dea
  join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
  Order by 2,3

  --To Calculate the % of Vaccinated Population Using CTE

  WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
  AS
  (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
  AS RollingPeopleVaccinated
  from [Portfolio Project]..[CovidDeaths] dea
  join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
  --Order by 2,3
  )
  Select *, (RollingPeopleVaccinated/Population)*100
  from PopvsVac

  --To Calculate the % of Vaccinated Population Using TEMP TABLE

  DROP TABLE IF exists #PercentPopulationVaccinated
  Create Table #PercentPopulationVaccinated (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

  INSERT INTO #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
  AS RollingPeopleVaccinated
  from [Portfolio Project]..[CovidDeaths] dea
  join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
  --Order by 2,3
  
  Select *, (RollingPeopleVaccinated/Population)*100
  from #PercentPopulationVaccinated


  --Creating View to store data later visualizations

  Create View PercentPopulationVaccinated AS
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
  AS RollingPeopleVaccinated
  from [Portfolio Project]..[CovidDeaths] dea
  join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select *
from PercentPopulationVaccinated