SELECT *
FROM PortfolioPro.dbo.CovidDeaths

SELECT *
FROM PortfolioPro.dbo.CovidVaccinations

--Data we are going to use
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioPro.dbo.CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying in country
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioPro.dbo.CovidDeaths
WHERE Location like '%states%'
and continent is not null
order by 1,2

--looking at total case vs population
--shows percentage of getting covid
SELECT Location,date,total_cases,Population,(total_cases/population)*100 as covidpercentage
FROM PortfolioPro.dbo.CovidDeaths
WHERE Location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
SELECT Location,MAX(total_cases) as highestinfectioncount,Population,MAX((total_cases/population))*100 as covidinfectedpercentage
FROM PortfolioPro.dbo.CovidDeaths
--WHERE Location like '%states%'
Group by Location,Population
order by highestinfectioncount desc

--showing countries with highest death count per population
SELECT Location, MAX(total_deaths) as totaldeathcount
FROM PortfolioPro.dbo.CovidDeaths
--WHERE Location like '%states%'
Where continent is not null
Group by Location
order by totaldeathcount desc

--Lets break thing terms by continents
SELECT continent ,MAX(total_deaths) as totaldeathcount
FROM PortfolioPro.dbo.CovidDeaths
--WHERE Location like '%states%'
Where continent is not null
Group by continent
order by totaldeathcount desc


--Global Numbers
SELECT SUM(new_cases) as total_cases ,Sum(new_deaths) as total_deaths,(Sum(new_deaths)/SUM(new_cases))*100 as deathpercentage
FROM PortfolioPro.dbo.CovidDeaths
--WHERE Location like '%states%'
Where continent is not null
--Group By date
order by 1,2


--looking at total population vs vaccination

Select dea.continent,dea.population,dea.Location,dea.date,vac.new_vaccinations,SUM(vac.new_vaccinations)
OVER (PARTITION BY dea.Location Order By dea.Location ,dea.date) as RollingVacc
--,(RollingVacc/population)*100
From PortfolioPro.dbo.CovidDeaths as dea
JOIN PortfolioPro.dbo.CovidVaccinations as vac 
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--using CTE

With PopvsVacc(continent,date,population,RollingVacc,Location,new_vaccination)
as
(
Select dea.continent,dea.population,dea.Location,dea.date,vac.new_vaccinations,SUM(vac.new_vaccinations)
OVER (PARTITION BY dea.Location Order By dea.Location ,dea.date) as RollingVacc
--,(RollingVacc/population)*100 u cannot use it after creating it so we use cte or temp table
From PortfolioPro.dbo.CovidDeaths as dea
JOIN PortfolioPro.dbo.CovidVaccinations as vac 
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
)
Select * ,(RollingVacc/population)*100
From PopvsVacc

--Temp table

Drop table if exists #Percentpopvacc
Create table #Percentpopvacc
(
Continent nvarchar(255),
Date datetime,
Location nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingVacc numeric
)

Insert into #Percentpopvacc
Select dea.continent,dea.population,dea.Location,dea.date,vac.new_vaccinations,SUM(vac.new_vaccinations)
OVER (PARTITION BY dea.Location Order By dea.Location ,dea.date) as RollingVacc
--,(RollingVacc/population)*100 u cannot use it after creating it so we use cte or temp table
From PortfolioPro.dbo.CovidDeaths as dea
JOIN PortfolioPro.dbo.CovidVaccinations as vac 
ON dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 1,2,3

Select * ,(RollingVacc/population)*100
From #Percentpopvacc


--Creating View for later Viualization

Create VIEW PercentPopulationVaccination as
Select dea.continent,dea.population,dea.Location,dea.date,vac.new_vaccinations,SUM(vac.new_vaccinations)
OVER (PARTITION BY dea.Location Order By dea.Location ,dea.date) as RollingVacc
--,(RollingVacc/population)*100 u cannot use it after creating it so we use cte or temp table
From PortfolioPro.dbo.CovidDeaths as dea
JOIN PortfolioPro.dbo.CovidVaccinations as vac 
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3

Select * From PercentPopulationVaccination