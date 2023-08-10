/*
Covid 19 Indonesia Data Exploration 

Skills yang digunakan: Joins, CTE, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

use portofolio
select * from coviddeath
where continent is not null
order by 3, 4

--select data that we are going to be using

select location, date, new_cases, total_cases, total_deaths, population 
from coviddeath
order by 1,2

--looking total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as persen_kematian 
from coviddeath
where location like '%indonesia%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population infected with covid

select location, date, total_cases, population, (total_cases/population)*100 as persen_infected
from coviddeath
where location like '%indonesia%'
order by 1,2

--countries with highest infection rate compared to population

select location, population,  max(total_cases) as maks, max((total_cases/population)*100) as maks_persen 
from coviddeath
--where location like '%indonesia%'
group by location, population
order by maks_persen desc

--showing countries with highest death counts per population

select location,  max(cast(total_deaths as int)) as total_death
from coviddeath
--where location like '%indonesia%'
where continent is not null
group by location
order by total_death desc


--lets breaking things down by continent

-- Showing contintents with the highest death count per population

select continent,  max(cast(total_deaths as int)) as maks_death
from coviddeath
--where location like '%indonesia%'
where continent is not null
group by continent
order by maks_death desc

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as deathpercentage
from coviddeath
--where location like '%indo%' 
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join Vaksinasi vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

with popvsvak (continent, location, date, population, new_vaccinations, roll) as
(
select dea.continent, dea.location, dea.date, dea.population, vak.new_vaccinations, sum(convert(int, vak.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as roll
--(roll/population)*100
from coviddeath dea
join vaksinasi vak
on dea.location = vak.location
and dea.date = vak.date
where dea.continent is not null
--order by 2,3
)
select * , (roll/population)*100
from popvsvak


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
create table #persenpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
roll numeric)

insert into #persenpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vak.new_vaccinations, sum(convert(int, vak.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as roll
--(roll/population)*100
from coviddeath dea
join vaksinasi vak
on dea.location = vak.location
and dea.date = vak.date
--where dea.continent is not null
--order by 2,3

select * , (roll/population)*100
from #persenpopulationvaccinated


-- Creating View to store data for later visualizations

create view persenpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vak.new_vaccinations, sum(convert(int, vak.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as roll
--(roll/population)*100
from coviddeath dea
join vaksinasi vak
on dea.location = vak.location
and dea.date = vak.date
where dea.continent is not null
--order by 2,3


select * from persenpopulationvaccinated