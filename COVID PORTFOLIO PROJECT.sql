

SELECT *
FROM [PORTFOLIO PROJECT]..CovidDeaths$
where continent is not null
Order by 3,4

--SELECT *
--FROM [PORTFOLIO PROJECT]..CovidVaccinations$
--Order by 3,4 

--SELECT DATA TO BE USED

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PORTFOLIO PROJECT]..CovidDeaths$
Order by 1,2 

--calculating Total_cases vs Total_deaths

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
 Where continent is not null
Order by 1,2 

--The likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
 where location like '%Nigeria%'
 and continent is not null
Order by 1,2 

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
 where location like '%state%'
 and continent is not null
Order by 1,2


--calculating Total_cases vs Population
---- show what percentage of population got covid
SELECT location, date,Population, total_cases, (Total_cases/Population) * 100 as PopolationPercentageInfected
FROM [PORTFOLIO PROJECT]..CovidDeaths$
--where location like '%state%'
where continent is not null
Order by 1,2 

--country with Highest Infection Rate compared to Population
SELECT location,Population, Max(total_cases) as HighestInfectionCount, Max(Total_cases/Population) * 100 as PopolationPercentageInfected
FROM [PORTFOLIO PROJECT]..CovidDeaths$
--where location like '%state%'
where continent is not null
Group by location, population
Order by PopolationPercentageInfected desc

-- countries with the Highest death count per Population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [PORTFOLIO PROJECT]..CovidDeaths$
--where location like '%state%'
where continent is not null
Group by location, population
Order by TotalDeathCount desc

-- Let's break down by Countinent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [PORTFOLIO PROJECT]..CovidDeaths$
--where location like '%state%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- countries with the Highest death count per Population using null
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From [PORTFOLIO PROJECT]..CovidDeaths$
--where location like '%state%'
where continent is  null
Group by location
Order by TotalDeathCount desc


--The Continents with the highest death ount per Population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [PORTFOLIO PROJECT]..CovidDeaths$
--where location like '%state%'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBER

SELECT  SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
 Where continent is not null
 --Group by date
Order by 1,2 


--Total Population vs  vaccination  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   , SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER by dea.location,
   dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population * 100
 FROM [PORTFOLIO PROJECT]..CovidDeaths$ dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations$ vac
 ON dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   Order by 2,3 

   --USING CTE

   with PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
   as
   (
   SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
   SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER by dea.location,
   dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population * 100
FROM  [PORTFOLIO PROJECT]..CovidDeaths$ dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations$ vac
 ON  dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
  -- Order by 2,3 
   )  

   Select *, (RollingPeopleVaccinated/Population) * 100
   From PopvsVac




   --Temp table
   DROP TABLE IF EXISTS  #PercentaePopulationVaccinated
   create table #PercentaePopulationVaccinated
   (
   continent nvarchar(255),
   location nvarchar(255),
   Date datetime,
   Population numeric,
   new_vaccinations numeric,
   RollingPeopleVaccinated numeric
   )
   Insert into #PercentaePopulationVaccinated
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER by dea.location,
   dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population * 100
FROM  [PORTFOLIO PROJECT]..CovidDeaths$ dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations$ vac
 ON  dea.location = vac.location
   and dea.date = vac.date
  -- where dea.continent is not null
  -- Order by 2,3 
  Select *, (RollingPeopleVaccinated/Population) * 100
   From #PercentaePopulationVaccinated




   --Creating View to store data for later visualition
    
   CREATE View PercentaePopulationVaccinated as 
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location ORDER by dea.location,
   dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population * 100
FROM  [PORTFOLIO PROJECT]..CovidDeaths$ dea
JOIN [PORTFOLIO PROJECT]..CovidVaccinations$ vac
 ON  dea.location = vac.location
   and dea.date = vac.date
  where dea.continent is not null
 -- Order by 2,3 
  
  SELECT *
FROM PercentaePopulationVaccinated