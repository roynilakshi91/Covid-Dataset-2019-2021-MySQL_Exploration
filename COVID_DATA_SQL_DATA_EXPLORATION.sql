#SELECT location , date , total_cases , new_cases , total_deaths, population FROM NILAKSHIDB.`covid-2021-deaths`
#order by 3,4;
#SELECT * FROM NILAKSHIDB.`covid-2021-vaccination`
#order by 3,4


# Select Data that we are using
#Select location, date, total_cases, new_cases, total_deaths, population from NILAKSHIDB.`covid-2021-deaths` order by 1,2

#Total cases vs Total deaths- Death percenatage in United States
#Shows the likelihood of dying if you contract covid in United States

 #Select location, date, total_cases,total_deaths, (total_deaths)/(total_cases)*100 AS death_percentage, population from NILAKSHIDB.`covid-2021-deaths` where location like "%states%" order by 1,2

# total cases VS population
# shows what percentage of population got Covid in United States

#Select location, date, population ,total_cases, (total_deaths)/(population)*100 AS covid_infected_percentage, population from NILAKSHIDB.`covid-2021-deaths` order by 1,2

# Country with highest infection rate compared to population
#Select location,population ,MAX(total_cases) AS highest_infection_count, MAX((total_deaths/population))*100 AS covid_infected_percentage from NILAKSHIDB.`covid-2021-deaths` group by location, population order by covid_infected_percentage DESC

#Countries with Highest death count per population
#Casting highest_death_count to Integer
Select location, MAX(Cast(total_deaths AS UNSIGNED)) AS highest_death_count FROM NILAKSHIDB.`covid-2021-deaths` 
where continent IS NOT NULL 
group by location 
order by highest_death_count DESC

#SELECT * FROM NILAKSHIDB.`covid-2021-deaths`
#where location = "world"
#order by 3,4

#Lets see which continent has higest deaths OR "continent is not NULL"
#Select continent, MAX(Cast(total_deaths AS UNSIGNED)) AS highest_death_count FROM NILAKSHIDB.`covid-2021-deaths`  where continent != "" group by continent order by highest_death_count DESC

#Lets see which location has higest deaths where continent is NULL
#Select location, MAX(Cast(total_deaths AS UNSIGNED)) AS highest_death_count FROM NILAKSHIDB.`covid-2021-deaths`  where continent = "" group by location order by highest_death_count DESC

#Global Numbers on new cases and new deaths

Select date ,SUM(new_cases)AS total_cases, SUM(Cast(new_deaths AS UNSIGNED)) AS total_deaths, SUM(Cast(new_deaths AS UNSIGNED))/SUM(Cast(new_cases AS UNSIGNED)) AS death_percentage from NILAKSHIDB.`covid-2021-deaths`
where continent is NOT NULL
group by date
order by 1,2

#Covid Vaccination
SELECT * FROM NILAKSHIDB.`covid-2021-vaccination`
order by 3,4


#JOIN both the tables together

SELECT * FROM NILAKSHIDB.`covid-2021-deaths` AS dea
JOIN NILAKSHIDB.`covid-2021-vaccination` AS vac
ON
dea.location = vac.location
AND
dea.date = vac.date


#Total population Vs Total Vaccination (new_vaccinations per day)

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations FROM NILAKSHIDB.`covid-2021-deaths` AS dea
JOIN NILAKSHIDB.`covid-2021-vaccination` AS vac
ON
dea.location = vac.location
AND
dea.date = vac.date
WHERE dea.continent is NOT NULL
order by 2,3


#Rolling Count  - Population VS vaccination
#Using Common Table Expression

WITH CTE (continent,location, date, Population,new_vaccinations, RollingPeopleVaccinate)
AS
(SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinate
FROM NILAKSHIDB.`covid-2021-deaths` AS dea
JOIN NILAKSHIDB.`covid-2021-vaccination` AS vac
ON
dea.location = vac.location
AND
dea.date = vac.date
#WHERE dea.continent is NOT NULL)
)

Select * , (RollingPeopleVaccinate/population)*100 FROM CTE 


#Temp table
USE NILAKSHIDB;

DROP TABLE IF EXISTS PercentPopulationVaccinations;
Create Table PercentPopulationVaccinations (Continent varchar(255),
Location varchar(255),
Date datetime,
Population BIGINT,
New_vaccinations varchar(255)
#RollingPeopleVaccinate varchar(255)
);

 
Insert into PercentPopulationVaccinations
SELECT dea.continent, dea.location,str_to_date(dea.date, '%m/%d/%Y %h:%i'), dea.population, vac.new_vaccinations
#SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinate
FROM NILAKSHIDB.`covid-2021-deaths` AS dea
JOIN NILAKSHIDB.`covid-2021-vaccination` AS vac
ON
dea.location = vac.location
AND
dea.date = vac.date
#WHERE dea.continent is NOT NULL)


Select *,
SUM(CAST(new_vaccinations AS SIGNED)) OVER (PARTITION BY location ORDER BY location, date) AS RollingPeopleVaccinate
  FROM PercentPopulationVaccinations 


#Creating a View to store data for later Visualization

Create View PercentPopulationVaccine AS
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinate
FROM NILAKSHIDB.`covid-2021-deaths` AS dea
JOIN NILAKSHIDB.`covid-2021-vaccination` AS vac
ON
dea.location = vac.location
AND
dea.date = vac.date


Select * from PercentPopulationVaccine




