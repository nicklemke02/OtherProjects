select *
from covidproject..coviddeaths
where continent is not null
order by 3,4


--select *
--from covidproject..covidvaccinations
--order by 3,4

--select data that we will use for Deaths
select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the total cases vs total deaths
select location, date, total_cases, total_deaths, (Total_Deaths/total_cases)*100 as PercentPopulationInfected
from CovidProject..CovidDeaths
where continent is not null
--where location = 'united states'
order by 1,2

--countries with the highest infection rate (compared to population)
select location, population, Max(total_cases) as HighestInfectionCount, max((Total_Cases/Population))*100 as PercentPopulationInfected
from CovidProject..CovidDeaths
where continent is not null
--where location = 'united states'
Group by Location, Population
order by PercentPopulationInfected desc

--countries with the highest death count (compared to population)
select Location, Population, Max(total_deaths) as TotalDeathCount, max((Total_Deaths/Population))*100 as PercentPopulationDead
from CovidProject..CovidDeaths
where continent is not null
--where location = 'united states
Group by Location, population
order by totaldeathcount desc

--continents with the highest death count
select Location, Max(total_deaths) as TotalDeathCount
from CovidProject..CovidDeaths
where continent is null
--where location = 'united states
Group by Location
order by totaldeathcount desc

--continents with the highest death count (for drilldown, incorrect)
select continent, Max(total_deaths) as TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null
--where location = 'united states
Group by continent
order by totaldeathcount desc

--Global numbers (2 steps to remove date for death %)
select location, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths,
case when sum (new_cases) = 0 then null
else sum(new_deaths) *100 / nullif(sum(new_cases),0)
end as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null
group by location
order by 4 desc


---------------------------------------------------------------------------------------------------------------------------------------------


--total population by location and vaccination accumulation
SELECT
    dea.Continent,
    dea.Location,
    dea.Date,
    dea.Population,
    vac.New_Vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinations,
    (SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.Population) * 100 AS VaccinationPercentage
FROM
    covidproject..coviddeaths dea
JOIN
    covidproject..covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    2, 3;


--Using CTE (incorrect)
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations, VaccinationPercentage)
AS
(
    SELECT
        dea.Continent,
        dea.Location,
        dea.Date,
        dea.Population,
        vac.New_Vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS CumulativeVaccinations,
        (SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) / CAST(dea.Population AS decimal(18, 4))) * 100 AS VaccinationPercentage
    FROM covidproject..coviddeaths dea
    JOIN covidproject..covidvaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, ((CumulativeVaccinations/Population)*100)/3 as VaccineOfPopPercentage
FROM PopvsVac
order by Population desc