Select *
From PortfolioProject.. covidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject.. covidVacinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covidDeaths
where continent is not null
order by 1,2

--home many cases in a country and how many deaths they have
--calculation deaths vs casess percentages

--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProject..covidDeaths
--order by 1,2

select 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CONVERT(DECIMAL(15, 2), total_deaths) / CONVERT(DECIMAL(15, 2), total_cases)*100 as [DeathPercentage]
from PortfolioProject..covidDeaths
where location like '%india%'
and continent is not null
order by 1,2

-- total_cases vs Population
--percentage of population got covid

select 
    location, 
    date, 
    total_cases, 
    population, 
    (total_cases / population)*100 as [percentPopulationInfected]
from PortfolioProject..covidDeaths
--where location like '%india%'
order by 1,2

--countries with highest infections rate compared to populations

select 
    location,
	population,
    MAX( CONVERT(DECIMAL(15), total_cases)) as HighestInfectionCount,  
    MAX((total_cases / population))*100 as percentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%india%'
Group by location, population
order by percentPopulationInfected desc


--countries with highestdeathcount

select 
    location,
	MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc

--sort by continent

select 
    continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--continents with highest death count per population

select 
    continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--global Numbers
select  
    date, 
    sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,
	sum(new_deaths)/sum(new_cases)*100 as [DeathPercentage]
    --CONVERT(DECIMAL(15, 2), total_deaths) / CONVERT(DECIMAL(15, 2), total_cases)*100 as [DeathPercentage]
from PortfolioProject..covidDeaths
--where location like '%india%'
where continent is not null
and new_cases != 0
group by date
order by 1,2

--

select  
    --date, 
    sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,
	sum(new_deaths)/sum(new_cases)*100 as [DeathPercentage]
    --CONVERT(DECIMAL(15, 2), total_deaths) / CONVERT(DECIMAL(15, 2), total_cases)*100 as [DeathPercentage]
from PortfolioProject..covidDeaths
--where location like '%india%'
where continent is not null
and new_cases != 0
--group by date
order by 1,2

--total population vaccinated

--select *
--from PortfolioProject..covidDeaths dea
--join PortfolioProject..covidVacinations vac
--     on dea.location = vac.location
--	 and dea.date =  vac.date

select 
      dea.continent,
	  dea.location,
	  dea.date,
	  dea.population,
	  vac.new_vaccinations,
	  sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.Date) as [RollingPeopleVaccinated]
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVacinations vac
     on dea.location = vac.location
	 and dea.date =  vac.date
where dea.continent is not null 
order by 2,3

--CTE

with PopvsVac (continent, location,date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select 
      dea.continent,
	  dea.location,
	  dea.date,
	  dea.population,
	  vac.new_vaccinations,
	  sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.Date) as [RollingPeopleVaccinated]
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVacinations vac
     on dea.location = vac.location
	 and dea.date =  vac.date
where dea.continent is not null 
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table

Drop table if exists #PercentPopulationvaccinated
create Table #PercentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationvaccinated
select 
      dea.continent,
	  dea.location,
	  dea.date,
	  dea.population,
	  vac.new_vaccinations,
	  sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.Date) as [RollingPeopleVaccinated]
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVacinations vac
     on dea.location = vac.location
	 and dea.date =  vac.date
--where dea.continent is not null 
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationvaccinated

-- creating view for visuallization
--drop view PercentPopulationvaccinated
create view PercentPopulationvaccinated
as
select 
      dea.continent,
	  dea.location,
	  dea.date,
	  dea.population,
	  vac.new_vaccinations,
	  sum(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.Date) as [RollingPeopleVaccinated]
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVacinations vac
     on dea.location = vac.location
	 and dea.date =  vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationvaccinated