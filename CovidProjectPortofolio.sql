Select *
From CovidDeaths
where continent is not null
order by 3, 4

Select *
From CovidVaccinations
order by 3,4


--- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1, 2

--- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) as Deaths
from CovidDeaths
where continent is not null
order by 1, 2


--- Looking at Percentage of  Total Cases vs Total Deaths
---Show likehood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from CovidDeaths
Where location like '%done%'
and continent is not null
order by 1, 2


---Looking at Total Cases Vs Total Population
--- Shows waht percentage of population got covid
Select Location, date, total_cases, population, (total_deaths/population)*100 as PercentagePopulation
from CovidDeaths
--Where location like '%done%'
order by 1, 2


---Looking at country with highest rate compares to population
Select Location, population, max(total_cases) as JumlahInfeksiMaksimum, Max(total_deaths/population)*100 as PercentagePopulationInfected
from CovidDeaths
group by location, population
order by PercentagePopulationInfected desc


---Showing Countries with Highest Deaths Count per Population
Select Location, max(cast(total_deaths as int)) as TotalDeathsCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathsCount desc


---Let's break things dwon by continent


--- Showing continent with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc



--Global Numbers

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPercentage--total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from CovidDeaths
--Where location like '%done%'
where continent is not null
--group by date
order by 1, 2


--Looking at Total Population Vs Vaccinations

Select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


---USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as RollingPeoplePercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeoplePercentage
From PopvsVac



---Temp Table

Drop table if exist #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as RollingPeoplePercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated



---Creating View to Store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as RollingPeoplePercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
from PercentPopulationVaccinated