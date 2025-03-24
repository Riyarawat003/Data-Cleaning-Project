
-- EXPLORATORY DATA ANALYSIS
-- EDA helps you to understand trends and patterns in the dataset, and in this we will focus on key areas such as layoffs by industry, layoffs over time, layoffs by country and top affected companies.

-- Step-1 Total Layoffs by Industry
-- Find out which industries had the most layoffs.
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Step-2 Layoffs Trend Over Time
-- Analyze how layoffs changed over different years.
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY year
ORDER BY year;

-- Step-3 Layoffs by Country
-- Find which countries had the highest number of layoffs.
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY country
ORDER BY total_layoffs DESC;

-- Step-4 Top 10 Companies with the Most Layoffs
-- Find the companies that laid off the most employees.
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Step-5 Percentage of Employees Laid Off Per Industry
-- Analyze which industries had the highest layoff percentages.
SELECT industry, ROUND(AVG(percentage_laid_off), 2) AS avg_layoff_percentage
FROM layoffs
GROUP BY industry
ORDER BY avg_layoff_percentage DESC;

-- Step-6 Companies with the Highest Layoff Percentage
-- Find companies that laid off the highest percentage of their workforce.
SELECT company, ROUND(AVG(percentage_laid_off), 2) AS avg_layoff_percentage
FROM layoffs
GROUP BY company
ORDER BY avg_layoff_percentage DESC
LIMIT 10;

-- Step-7 Layoffs by Company Stage
-- Find out if early-stage or late-stage companies were affected more.
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY stage
ORDER BY total_layoffs DESC;