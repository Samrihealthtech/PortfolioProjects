use samri

select * 
from samri..CovidDeaths
order by 3, 4

--select * 
--from samri..Covidvas
--order by 3, 4

select Location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--changeng data type

alter table Covidvas
alter column new_vaccinations float

alter table CovidDeaths
alter column total_cases Float;

alter table CovidDeaths
alter column population Float;

use Samri
alter table CovidDeaths
alter column new_deaths Float;

ALTER TABLE CovidDeaths 
ALTER COLUMN date DATE;

ALTER TABLE Covidvas
ALTER COLUMN date DATE;


---Total cases vs total Death---
----Shows the likelihood of dying in USA
select Location,date, total_cases, total_deaths,
case
when total_cases=0 then Null
else
(total_deaths/total_cases) * 100  
end AS DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2;

---- Looking at the total cases vs population- in USA
---Shows what percentages of 

SELECT Location, date, total_cases, population,
       CASE 
           WHEN population = 0 THEN NULL  -- Avoid division by zero
           ELSE (total_cases / population) * 100  
       END AS CasePercentage
FROM CovidDeaths
ORDER BY 1, 2;


--Looking ar countries with highest infection rate compared to population 


SELECT 
    Location, 
    Population, 
    MAX(total_cases) AS HighestInfectionRate, 
    CASE 
        WHEN Population = 0 THEN NULL  
        ELSE (MAX(total_cases) / Population) * 100  
    END AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC; 

---- COUNTRIES WITH HIGHEST DEATH COUNT 

----Showing the contintent with the highest death count per population 
SELECT 
    continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--GLOBAL NUMBERS 
 
SELECT 
   
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL  
        ELSE (SUM(new_deaths)) / SUM(new_cases) * 100 
    END AS DeathPercentage
FROM CovidDeaths
--GROUP BY date
ORDER BY 1,2;


---Total Population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.Date) as PeopleVaccinated

from CovidDeaths as dea
join Covidvas vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null and
dea.location like '%Albania%'
order by 2,3


with PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated) AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY dea.location ORDER BY dea.date
        ) AS PeopleVaccinated
    FROM CovidDeaths AS dea
    JOIN Covidvas AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    -- AND dea.location LIKE '%Albania%'  -- Uncomment this if needed
)

SELECT * , 
case when population = 0 then null else 
(PeopleVaccinated/population) *100 end
from PopvsVac


---Creating view to store


create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.Date) as PeopleVaccinated
from CovidDeaths as dea
join Covidvas vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated