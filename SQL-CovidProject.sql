select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

===================================================================================
-- total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

===================================================================================
-- total cases vs population. shows what %age of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

===================================================================================
-- looking at countries with highest infection rate compared to population

select location,population, max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths
 --- where location like '%states%'
group by location,population
order by Percentpopulationinfected desc

===================================================================================
-- showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths
 --- where location like '%states%'
 where continent is not null
group by location
order by TotalDeathcount desc
===================================================================================
-- lets break down by contineint 

-- showing the continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathcount
from PortfolioProject..CovidDeaths
 --- where location like '%states%'
 where continent is not null
group by continent
order by TotalDeathcount desc
===================================================================================
-- Global Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
-- group by date
order by 1,2
===================================================================================
 -- joined 2 tables deaths & vaccination. looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
=====================================================================================
-- using CTE

with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated / Population)*100 from popvsvac
=====================================================================================
-- Temp Table

create table #percentpopulationvaccinated
( continent nvarchar(255),location nvarchar(255),Date datetime,population NUMERIC,new_vaccinations NUMERIC,RollingPeopleVaccinated NUMERIC)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as BIGINT)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-- where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated / Population)*100 as PercRollingPeopleVaccinatedvsPopulation from #percentpopulationvaccinated

drop table if exist #percentpopulationvaccinated
SELECT * FROM #percentpopulationvaccinated

=====================================================================================
-- creating view to store data for visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as BIGINT)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
=====================================================================================

