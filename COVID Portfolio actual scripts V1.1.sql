Select *
From [Portfolio Project ].dbo.CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--From [Portfolio Project ].dbo.CovidVaccinations
--Order by 3,4

Select location, date , total_cases, new_cases, total_deaths, population
From [Portfolio Project ].dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Death
-- Show likelihood of dying if you contract in your country

Select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project ].dbo.CovidDeaths
Where location like '%states%'
And continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid

Select location, date , population, total_cases,  (total_cases/population)*100 as Select location, date , population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project ].dbo.CovidDeaths
--Where location like '%states%'
Order by 1,2
From [Portfolio Project ].dbo.CovidDeaths
Where continent is not null
--Where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population 

Select location, population, Max(total_cases) as HighestInfectionsCount, Max(total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project ].dbo.CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population 

Select location, max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project ].dbo.CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project ].dbo.CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS 

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/sum
(new_cases)*100 as DeathPercentage
From [Portfolio Project ].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccionated
--, (RollingPeopleVaccionated//population)*100
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations,  RollingPeopleVaccionated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccionated
--, (RollingPeopleVaccionated//population)*100
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccionated/Population)*100
From PopvsVac

-- TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccionated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccionated
--, (RollingPeopleVaccionated//population)*100
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccionated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccionated
--, (RollingPeopleVaccionated//population)*100
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
