# 🦠 COVID-19 Data Exploration Project

A comprehensive SQL analysis exploring global COVID-19 trends, mortality rates, and vaccination impact using real-world data from Our World in Data.

## 📊 Project Overview
This project analyzes COVID-19 infection and mortality trends across countries and continents, examining:
- Death percentage likelihood by location
- Population infection rates
- Rolling vaccination totals and coverage
- Global and continental trends

## 🛠️ Tools & Technologies
- **SQL** (MySQL)
- **Skills Used:** Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions, Views

## 📁 Project Structure
covid19-SQL-Analysis/
├── CovidAnalysis.sql # Complete analysis queries
├── CovidDeaths.csv # Daily cases & deaths data
├── CovidVac.csv # Vaccination data
└── README.md # Project documentation



## 🔍 Key Analysis Performed
1. **Death Percentage Analysis** - Calculated likelihood of dying if infected
2. **Infection Rate Analysis** - Percentage of population infected by country
3. **Highest Death Count** - Countries and continents with highest mortality
4. **Vaccination Impact** - Rolling vaccination totals and population coverage
5. **Global Trends** - Worldwide case and death statistics

## 💡 Key Findings
- **Highest mortality rates** observed in [specific countries/regions]
- **Vaccination rollout** showed [correlation/impact] on death rates
- **Regional disparities** identified between [regions]

## 🚀 How to Run
1. Import `CovidDeaths.csv` and `CovidVac.csv` into your MySQL database
2. Run `CovidAnalysis.sql` to execute all queries
3. Results include death percentages, infection rates, and vaccination coverage

## 📈 Sample Queries
```sql
-- Death Percentage Calculation
SELECT Location, date, total_cases, total_deaths,
       (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;
