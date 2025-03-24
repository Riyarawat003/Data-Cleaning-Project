-- Project: SQL Data Cleaning - Layoffs Dataset
-- Objective: Clean the raw layoffs data by handling missing values,
-- removing duplicates, standardizing text, converting data types, and
-- performing basic analysis.
-- ====================================================

-- 1. Explore the Dataset
-- -------------------

-- 1.1 View the first 10 rows to understand the data structure
SELECT * FROM layoffs LIMIT 10;

-- 1.2 Check column names and data types
DESC layoffs; 

-- 1.3 Count the total records
SELECT COUNT(*) from layoffs;

-- 1.4 Count the total number of rows
SELECT COUNT(*) AS total_rows FROM layoffs;

-- 1.5 Count the total number of columns
SELECT COUNT(*) AS total_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'layoffs';

-- 1.6 Check for duplicate rows
SELECT company, location, industry, total_laid_off, country, COUNT(*) AS count
FROM layoffs
GROUP BY company, location, industry, total_laid_off, country
HAVING COUNT(*) > 1;

-- 1.7 Count null values in each column
SELECT 
    SUM(CASE WHEN company IS NULL OR company = '' THEN 1 ELSE 0 END) AS null_company,
    SUM(CASE WHEN location IS NULL OR location = '' THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN industry IS NULL OR industry = '' THEN 1 ELSE 0 END) AS null_industry,
    SUM(CASE WHEN total_laid_off IS NULL THEN 1 ELSE 0 END) AS null_total_laid_off,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS null_country
FROM layoffs;

-- ====================================================
-- 2. Removing the duplicates
-- ====================================================

-- 2.1 Identify Duplicates
SELECT company, location, industry, total_laid_off, percentage_laid_off, 
       date, stage, country, funds_raised_millions, COUNT(*) 
FROM layoffs
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, 
         date, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;

-- The layoffs table does not have an id column or any unique identifier. To properly remove duplicates, we need to first add an id column
-- 2.2 Create a temporary table with row number
CREATE TABLE layoffs_temp AS 
SELECT *, 
       ROW_NUMBER() OVER
       (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
         date, stage, country, funds_raised_millions ORDER BY (SELECT NULL)
       ) As rn
FROM layoffs;

-- Delete Duplicates
DELETE FROM layoffs_temp WHERE rn > 1;

-- Replace the original table
DROP TABLE layoffs;
ALTER TABLE layoffs_temp RENAME TO layoffs;

-- ====================================================
-- 3. Handle Missing Values
-- ====================================================

-- 3.1 Check null values in eah columns
SELECT 
    SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS company_nulls,
    SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS location_nulls,
    SUM(CASE WHEN industry IS NULL THEN 1 ELSE 0 END) AS industry_nulls,
    SUM(CASE WHEN total_laid_off IS NULL THEN 1 ELSE 0 END) AS total_laid_off_nulls,
    SUM(CASE WHEN percentage_laid_off IS NULL THEN 1 ELSE 0 END) AS percentage_laid_off_nulls,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN stage IS NULL THEN 1 ELSE 0 END) AS stage_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN funds_raised_millions IS NULL THEN 1 ELSE 0 END) AS funds_raised_nulls
FROM layoffs;

-- 3.2 Handling the null values: percentage_laid_off
-- 3.1.1 Handle null values in percentage_laid_off (750 Nulls)
SELECT COUNT(*) 
FROM layoffs 
WHERE percentage_laid_off IS NULL AND total_laid_off IS NOT NULL;

 -- We will fill the missing value by using the average percentage per industry
-- 3.1.2 Check Industry-Wise Averages
SELECT industry, AVG(percentage_laid_off) AS avg_percentage
FROM layoffs
WHERE percentage_laid_off IS NOT NULL
GROUP BY industry;
select * from layoffs limit 5;

-- 3.1.3 Fill missing values using Industry Averages
UPDATE layoffs t1
JOIN (
    SELECT industry, AVG(percentage_laid_off) AS avg_percentage
    FROM layoffs
    WHERE percentage_laid_off IS NOT NULL
    GROUP BY industry
) t2
ON t1.industry = t2.industry
SET t1.percentage_laid_off = t2.avg_percentage
WHERE t1.percentage_laid_off IS NULL;

-- 3.1.4 Verify the changes
SELECT 
    COUNT(*)
FROM
    layoffs
WHERE
    percentage_laid_off IS NULL;

-- 3.2 Fix the null value in Date
SELECT * FROM layoffs WHERE date IS NULL;

-- 3.2.1 Check for a possible replacement date
SELECT * 
FROM layoffs 
WHERE company = 'blackbaud' 
AND date IS NOT NULL;

-- 3.2.2 Find Industry Trends
-- As no valid date is found for blackbaud, we will check if other companies in the same industry (“other”) have valid layoff dates:
SELECT industry, MAX(date) AS recent_date
FROM layoffs 
WHERE industry = 'other' 
AND date IS NOT NULL
GROUP BY industry;

-- 3.2.3 Update the missing date
UPDATE layoffs
SET date = '2023-03-06' 
WHERE company = 'blackbaud' 
AND date IS NULL;

-- 3.3 Fix Null in Stage (6 Nulls)
SELECT * FROM layoffs WHERE stage IS NULL;

-- 3.3.1 Find Existing Stage Values for the same companies
SELECT company, stage 
FROM layoffs 
WHERE company IN ('advata', 'gatherly', 'relevel', 'spreetail', 'verily', 'zapp') 
AND stage IS NOT NULL;

-- 3.3.2 Find the Most Common Stage for Their Industry
SELECT industry, stage, COUNT(*) as count
FROM layoffs
WHERE stage IS NOT NULL
GROUP BY industry, stage
ORDER BY industry, count DESC;

-- 3.3.3 Update Null Stages based on Industry
UPDATE layoffs l
JOIN (
    SELECT industry, stage
    FROM layoffs
    WHERE stage IS NOT NULL
    GROUP BY industry, stage
    ORDER BY COUNT(*) DESC
) t
ON l.industry = t.industry
SET l.stage = t.stage
WHERE l.stage IS NULL;

-- 3.3.4 Verify if Null Values still exist
Select count(*)
From layoffs
where stage is null;

-- ====================================================
-- 4. Standardizing Text Formatting
-- ====================================================
-- 4.1 Convert Text Columns to Lowercase
UPDATE layoffs
SET company = LOWER(company),
    location = LOWER(location),
    industry = LOWER(industry),
    country = LOWER(country);

-- 4.2 Trim Extra Spaces
UPDATE layoffs
SET company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    country = TRIM(country);
    
-- 4.3 Standardize the Industry Column
-- 4.3.1 Analyze the current Industry data
SELECT DISTINCT industry FROM layoffs ORDER BY industry;

-- 4.3.2 Mapping the data and updating the Industry Column
UPDATE layoffs
SET industry = 'crypto currency'
WHERE LOWER(TRIM(industry)) IN ('crypto', 'cryptocurrency');

UPDATE layoffs
SET industry = 'fintech'
WHERE LOWER(TRIM(industry)) IN ('fin-tech', 'financial technology');

-- 4.4 Standardize the Company Column
-- 4.3.1 Analyze the current Company Column
SELECT DISTINCT company FROM layoffs ORDER BY company;

-- 4.3.2 Manual mapping for specific Cases
UPDATE layoffs
SET company = 'paid'
WHERE company = '#paid';

-- ====================================================
-- 5. Convert Data Type
-- ====================================================

-- 5.1 Convert the 'date' column to DATE type 
-- 5.1.1 Check current date format
SELECT DISTINCT date FROM layoffs;

-- 5.1.2 Convert Text to Proper Format
-- As the format is MM/DD/YYYY, we will convert it
UPDATE layoffs
SET date = STR_TO_DATE(date, '%m/%d/%Y')
WHERE date IS NOT NULL;

-- 5.1.3 Check for Invalid Dataset
SELECT date FROM layoffs WHERE STR_TO_DATE(date, '%m/%d/%Y') IS NULL;

-- 5.1.4 Change column data type
ALTER TABLE layoffs
MODIFY COLUMN date DATE;

-- ====================================================
-- 6. Remove Incorrect or Test Data
-- ====================================================

-- 6.1 Identify Incorrect Entries
SELECT * FROM layoffs
WHERE company LIKE '%test%' OR company = '' OR total_laid_off < 0;

-- 6.2 Delete Incorrect Data
DELETE FROM layoffs
WHERE company LIKE '%test%' OR company = '' OR total_laid_off < 0; 

-- ====================================================
-- 7. Final Verifying the data
-- ====================================================
 
-- 7.1 Check for Null Values are removed
SELECT 
    SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS company_nulls,
    SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS location_nulls,
    SUM(CASE WHEN industry IS NULL THEN 1 ELSE 0 END) AS industry_nulls,
    SUM(CASE WHEN total_laid_off IS NULL THEN 1 ELSE 0 END) AS total_laid_off_nulls,
    SUM(CASE WHEN percentage_laid_off IS NULL THEN 1 ELSE 0 END) AS percentage_laid_off_nulls,
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN stage IS NULL THEN 1 ELSE 0 END) AS stage_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN funds_raised_millions IS NULL THEN 1 ELSE 0 END) AS funds_raised_nulls
FROM layoffs;

-- 7.2 Duplicate records are completely removed
SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions, count(*)
FROM layoffs
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;

-- 7.3 Verify Data Types are correct
DESC layoffs;

-- 7.4 Check for inconsistent text formatting
SELECT DISTINCT industry FROM layoffs ORDER BY industry;
SELECT DISTINCT company FROM layoffs ORDER BY company;










