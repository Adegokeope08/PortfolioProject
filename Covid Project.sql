
--select *
--from PortfolioProject..CovidDeath1$
--order by 3,4

--select *
--from PortfolioProject..CovidVaccination$
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath1$
order by 1,2

--Looking at Total Cases vs Total Deaths


select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath$
order by 1,2


select *
from PortfolioProject..CovidVaccination$
order by 3,4

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath$
where location like '%nigeria%'
order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath$
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Show what percentage of population got covid

select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeath$
where location like '%states%'
order by 1,2

select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeath$
where location like '%Nigeria%'
order by 1,2

--Looking at country with highest infection rate compare to population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeath$
--where location like '%Nigeria%'
Group by Location, Population
order by PercentagePopulationInfected desc


--Showing Country with the Highest death count per population

select Location, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath$
--where location like '%Nigeria%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Breaking it down by Continent

select Continent, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath$
--where location like '%Nigeria%'
where continent is not null
Group by Continent
order by TotalDeathCount desc

--Breaking it down by Location

select Location, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath$
--where location like '%Nigeria%'
where continent is null
Group by Location
order by TotalDeathCount desc


--Breaking it down by Continent

select Continent, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath$
--where location like '%Nigeria%'
where continent is not null
Group by Continent
order by TotalDeathCount desc

--Showing the continent with highest death count

select Continent, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath$
--where location like '%Nigeria%'
where continent is not null
Group by Continent
order by TotalDeathCount desc


--Global Numbers

 select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath$
--where location like '%nigeria%'
where continent is not null
Group by date
order by 1,2

--Looking at Total Population VS Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using CTE
with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

--Temp Table
drop table if exist #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #percentpopulationvaccinated

--Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated