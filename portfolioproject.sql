
select *
from PortfolioProject.dbo.coviddeaths
--where continent is null
order by 3,4

--select *
--from PortfolioProject.dbo.covidvaccinations$
--order by 3,4 

select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject.dbo.coviddeaths
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in Nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject.dbo.coviddeaths
where lower(location) like '%nigeria%'
order by 1,2



--looking at the total cases vs population
--shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
from PortfolioProject.dbo.coviddeaths
where lower(location) like '%nigeria%'
order by 1,2


-- looking at countries with high infection rates in relation to population
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentpopulationinfected
from PortfolioProject.dbo.coviddeaths
--where lower(location) like '%nigeria%'
group by location,population
--order by percentpopulationinfected desc
order by location


--showing countries with highest deathcount by location
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
--where lower(location) like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc


-- SHOWING COUNTRIES WITH HIGHEST DEATHCOUNT PER POPULATION
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
--where lower(location) like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc



--BREAKING THINGS DOWN BY CONTINENT



--showing continents with their death count
 select location, continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where lower(location) like '%nigeria%'
where continent is null
group by continent, location
order by TotalDeathCount desc


--showin the continents with the highest eath count
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
where continent is  null
group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortfolioProject.dbo.coviddeaths
where continent is not null
--group by date
order by 1,2





--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.Date)
 as SumofVaccinatedPopulation
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3





--USE CTE

With PopvsVac (continent, location, date, population, New_vaccinations, SumofVaccinatedPopulation)
as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.Date)
 as SumofVaccinatedPopulation
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (SumofVaccinatedPopulation/population)*100
from PopvsVac





--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
loaction nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
SumofVaccinatedPopulation numeric
) 


 INSERT INTO  #PercentPopulationVaccinated
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.Date)
 as SumofVaccinatedPopulation
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
 on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3              

select *, (SumofVaccinatedPopulation/population)*100
from #PercentPopulationVaccinated



--CREating views
Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.Date)
 as SumofVaccinatedPopulation
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


CREATE VIEW 
continentdeathcount as
select location, continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where lower(location) like '%nigeria%'
where continent is null
group by continent, location
--order by TotalDeathCount desc
