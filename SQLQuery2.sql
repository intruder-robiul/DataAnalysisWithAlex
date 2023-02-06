select *
from PortfolioPro..CovidDeaths
order by 3,4


select location, Date, total_cases, new_cases, total_deaths, population
from PortfolioPro..CovidDeaths
order by 1,2 

--% death vs infected in USA

select location, Date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioPro..CovidDeaths
where location like '%states%'
order by 1,2

--% death vs infected in Bangladesh

select location, Date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioPro..CovidDeaths
where location like '%bangladesh%'
order by 1,2

--country sorted by infection rate vs population 

select location,  population, max(total_cases) as highestInfected,  Max(total_cases/population)*100 as maxInfectionRate
from PortfolioPro..CovidDeaths
Group by location,  population
order by maxInfectionRate desc

--countries sorted by total deaths 

select location,  max(Cast(total_deaths as int)) as Death
from PortfolioPro..CovidDeaths
where continent is not null
Group by location
order by Death desc

--contnents sorted by total deaths 

select location, max(cast(total_deaths as int)) as deaths
from PortfolioPro..CovidDeaths
where continent is null
Group by location
order by deaths desc

--continents sorted by highest death rate vs population 

select location, population, cast(total_deaths as int),  (total_deaths/population)*100 as deathrate
from PortfolioPro..CovidDeaths
where continent is null
Group by location, population
order by deathrate desc

--% of death globally by dates

select date, sum(cast(new_deaths as int)) as new_death, sum(new_cases) as new_cases, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentDeath
from PortfolioPro..CovidDeaths
where continent is not null
Group by date
order by 1,2

--% of death globally final

select  sum(cast(new_deaths as int)) as new_death, sum(new_cases) as new_cases, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentDeath
from PortfolioPro..CovidDeaths
where continent is not null
order by 1,2



-- total people vaccinated against population

select vac.continent, vac.location, vac.date, dea.population,  vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as vaccinatedPeople
from PortfolioPro..CovidVaccinations vac
join PortfolioPro..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where vac.continent is not null
order by 2,3




-- % of total people vaccinated against population using CTE

with popvsvac (continent, location, date, population, new_vaccinations, peopleVaccinated)
as
(
select vac.continent, vac.location, vac.date, dea.population,  vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by vac.location, vac.date) as vaccinatedPeople
from PortfolioPro..CovidVaccinations vac
join PortfolioPro..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where vac.continent is not null
--order by 2,3
)

select *, peopleVaccinated/population*100 as percentVaccinated
from popvsvac
order by 2,3


-- % of total people vaccinated against population using Temp Table

drop table if exists percentPopVaccinated
create table percentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinatedPeople numeric
)

insert into percentPopVaccinated
select vac.continent, vac.location, vac.date, dea.population,  vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by vac.location, vac.date) as vaccinatedPeople
from PortfolioPro..CovidVaccinations vac
join PortfolioPro..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where vac.continent is not null
--order by 2,3

select *, (vaccinatedPeople/population)*100
from percentPopVaccinated
order by 2,3

--creating views for later visualisation

create view PercentPopulationVaccinated as
select vac.continent, vac.location, vac.date, dea.population,  vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by vac.location order by vac.location, vac.date) as vaccinatedPeople
from PortfolioPro..CovidVaccinations vac
join PortfolioPro..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where vac.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated 