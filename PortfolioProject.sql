use PortfolioProject;
SELECT *
FROM PortfolioProject..CovidVaccinations$;

-- SELECT *
-- FROM PortfolioProject..CovidDeaths$
-- ORDER BY 3,4;

select location, date, total_cases, total_deaths, population
from CovidDeaths$
order by 1,2

-- total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100  death_percentage
from CovidDeaths$
where location like '%Nep%'
order by 1,2

-- total cases vs population
select location, date, total_cases, population, (total_cases/population) * 100  death_percentage
from PortfolioProject..CovidDeaths$
where location like '%Nep%'
order by 1,2

select location, total_cases, population
from CovidDeaths$

select total_cases, location
from CovidDeaths$

-- total cases recoreded of all countries
select location, COUNT(location)
from CovidDeaths$
group by location


 select Location, count(total_cases)
 from CovidDeaths$
 group by Location

select location, Population, MAX(total_cases)  as HighestCaseRecorded
from CovidDeaths$
group by location, population
order by HighestCaseRecorded desc;

-- coutries with highest infection rate compared to population
select location, Population, MAX(total_cases)  as HighestCaseRecorded, MAX((total_cases/population))*100 as populationInfectedByPercentage
from CovidDeaths$
group by location, population
order by populationInfectedByPercentage desc;

-- death counts highest
-- total_deaths is in character change to int
select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null -- removed null values like asia and world
Group by Location
order by TotalDeathCount desc;

-- continent is in null 
-- highest continent death
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc;

select * 
from CovidDeaths$
where continent is not null
 
 -- total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as peopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE
with popvsvac (continent, Location, Date, Population,New_Vaccination, peopleVaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as peopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
--select *
-- from popvsvac
select *, (peopleVaccinated/Population) * 100
from popvsvac

-- drop table if exists #percentpopulationVaccinated #if you want to change or edit
create table #percentPopulationVaccinated
(
continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
new_vaccinations numeric,
peopleVaccinated numeric
)
insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as peopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (peopleVaccinated/Population) * 100
from #percentPopulationVaccinated

-- creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.Date) as peopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3