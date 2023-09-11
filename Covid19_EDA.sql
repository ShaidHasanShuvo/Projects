/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Exploring the data to find out the primary keys
Select *
From Covid19_Project..CovidDeaths
order by 3,4


-- Select Data that we are going to be working with

Select Continent,Location, date, population, total_cases, new_cases, total_deaths
From Covid19_Project..CovidDeaths
Where continent is not null 
order by 2,3


-- Total Cases vs Total Deaths

Delete
From Covid19_Project..CovidDeaths
Where total_cases=0 -- To avoid errors because total_cases shouldn't be a ZERO

-- To identify the Death percentage along with total cases

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19_Project..CovidDeaths
Where location like '%Bangladesh%'
order by 1,2


-- Total Cases vs Population

Delete
From Covid19_Project..CovidDeaths
Where population=0 -- To avoid errors because Population shouldn't be a ZERO

-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Covid19_Project..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Location with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid19_Project..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Location with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From Covid19_Project..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount Desc




-- Contintents with the highest death count per population

Select continent, MAX(Total_deaths ) as TotalDeathCount
From Covid19_Project..CovidDeaths
Where continent is not null -- First row shows the total death count Worldwide
Group by continent
order by TotalDeathCount desc

-- Rechecking the number of Continent
Select Distinct(Continent) as Continent_Count
From Covid19_Project..CovidDeaths
Order By Continent_Count -- -- First row shows the total death count World

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From Covid19_Project..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(vaccine.new_vaccinations) OVER (Partition by death.Location Order by death.Date) as CumulativePeopleVaccinated
From Covid19_Project..CovidDeaths death
Join Covid19_Project..Covid_Vaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
order by 2,3


-- Using CTE to perform Calculate Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativePeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(vaccine.new_vaccinations) OVER (Partition by death.Location Order by death.Date) as CumulativePeopleVaccinated
From Covid19_Project..CovidDeaths death
Join Covid19_Project..Covid_Vaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
)
Select Location, Population, CumulativePeopleVaccinated as TotalVaccinated,(CumulativePeopleVaccinated/Population)*100 as PercentageAtleast_1Vaccinated
From PopvsVac
where Location like '%Bangladesh%' -- For a specific location
Order by PercentageAtleast_1Vaccinated Desc



-- Using Temp Table to perform Calculate Percentage of Population that has recieved at least one Covid Vaccine

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(vaccine.new_vaccinations) OVER (Partition by death.Location Order by death.Date) as CumulativePeopleVaccinated
From Covid19_Project..CovidDeaths death
Join Covid19_Project..Covid_Vaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
order by 2,3


Select *, (CumulativePeopleVaccinated/Population)*100 as PercentageAtleast_1Vaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentageVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(vaccine.new_vaccinations) over (Partition by death.location Order By death.date) as CumulativePeopleVaccinated
From Covid19_Project..CovidDeaths death
Join Covid19_Project..Covid_Vaccinations vaccine
	on death.location=vaccine.location
	and death.date=vaccine.date
where death.continent is not null

Select *
From Covid19_Project..PercentageVaccinated