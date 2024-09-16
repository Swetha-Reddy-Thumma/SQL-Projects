/*
Covid 19 Data Exploration (Data is from Year-2021)

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

USE [Covid-19];

Select * from
CovidDeaths
order by 3,4;


-- Select Data that we are going to starting with

Select location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population
from CovidDeaths
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location,
		date,
		total_cases,
		total_deaths,
		(total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location like '%states%'
order by 1,2;


-- Total Cases VS Population
-- Shows what percentage of population infected with covid

Select location,
		date,
		population,
		total_cases,
		(total_cases/population)*100 as Infected_Percentage
from CovidDeaths
where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select location,
		population,
		MAX(total_cases) as Highest_Infection_Count,
		MAX((total_cases/population)*100) as Infected_Percentage
from CovidDeaths
Group by location,population
order by Infected_Percentage desc;


-- Countries with Highest Death Count per Population

Select location,
		population,
		MAX(cast(total_deaths as int)) Total_Death_Counts
from CovidDeaths
where continent is not null
Group by location,population
order by Total_Death_Counts desc


-- BREAKING THINGS BY CONTINENT

-- Showing contintents with the highest death count per population

Select  continent,
		MAX(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
where continent is not null
Group by continent
order by Total_Death_Count desc


-- GLOBAL NUMBERS

-- Total Cases vs Total Deaths and Death Percentage per day

Select date,
		SUM(new_cases) as total_cases,
		SUM(cast(new_deaths as int)) as total_deaths,
		SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Total Cases vs Total Deaths in the world

Select SUM(new_cases) as total_cases,
		SUM(cast(new_deaths as int)) as total_deaths,
		SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null
order by 1,2


-- VACCINATIONS TABLE

Select *
from CovidVaccinations
order by 3,4;


-- Total Population VS Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(CONVERT(int, v.new_vaccinations)) OVER (partition by d.location Order by d.location,d.date) as Rolling_People_Vacinated
from CovidDeaths as d 
join CovidVaccinations as v
	on d.location = v.location 
	   and d.date = v.date
WHERE d.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select  d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(CONVERT(int, v.new_vaccinations)) OVER (partition by d.location Order by d.location,d.date) as Rolling_People_Vaccinated
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
Select *,
		(Rolling_People_Vaccinated/population)*100 as Percentage_Vaccinated
from PopvsVac
order by Location, Date



-- Using TEMP TABLE to perform Calculation on Partition By in previous query


Drop Table if exists #Percent_Population_Vaccinated

Create Table #Percent_Population_Vaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select  d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(CONVERT(int, v.new_vaccinations)) OVER (partition by d.location Order by d.location,d.date) as Rolling_People_Vaccinated
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null


Select *,
		(Rolling_People_Vaccinated/population)*100 as Percentage_Vaccinated
from #Percent_Population_Vaccinated
order by Location, Date



-- Creating View to store data for kater visualizations

CREATE VIEW Percent_Population_Vaccinated 
as 
Select  d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(CONVERT(int, v.new_vaccinations)) OVER (partition by d.location Order by d.location,d.date) as Rolling_People_Vaccinated
from CovidDeaths as d
join CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

