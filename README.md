DATA CLEANING PROJECT - Layoffs Dataset

# Project Overview
The goal of this project is to clean and prepare the Layoffs dataset by handling missing values, duplicates, incorrect formats and inconsistent data using SQL.

# Skills Used
- Data Cleaning in SQL
- Handling NULL values and missing data
- Removing duplicate records
- Standardizing text formatting (uppercase/lowercase, trimming spaces)
- Converting data types (e.g., text to date/numbers)
- Exploratory Data Analysis (EDA) using SQL queries

# Dataset Details
- Dataset Name: Layoffs  
- Total Rows: 2,361
- Total Columns: 27  

# Dataset Information
- Columns:
  - company: Name of the company  
  - location: City or country of the company  
  - industry: Industry type  
  - total_laid_off: Number of layoffs  
  - percentage_laid_off: Percentage of employees laid off  
  - date: Date of layoff event  
  - stage: Business stage of the company  
  - country: Country where layoffs happened  
  - funds_raised_millions: Funds raised by the company before layoffs  

# Data Cleaning Process
The dataset was cleaned using SQL queries in MySQL Workbench following these structured steps:
1 Exploring the Dataset
	•	Loaded the raw dataset into MySQL.
	•	Checked the number of rows and columns.
	•	Identified issues like missing values, duplicate records, inconsistent text formatting, incorrect data types, and test data.
2. Removing Duplicates
	•	Identified and removed exact duplicate rows to avoid redundancy.
	•	Used the ROW_NUMBER() function to flag and delete duplicate entries.
3. Handling Missing Values
	•	Checked for missing (NULL) values in critical columns.
	•	Replaced NULL values with "Unknown" or relevant replacements based on industry patterns.
4. Standardizing Text Formatting
	•	Converted all text columns to lowercase for consistency.
	•	Trimmed extra spaces and standardized company and industry names.
5. Converting Data Types
	•	Ensured total_laid_off and funds_raised_millions were stored as INT.
	•	Checked and converted percentage_laid_off to DECIMAL(5,2).
	•	Standardized date format to DATE.
6. Removing Incorrect or Test Data
	•	Identified and removed unrealistic values (e.g., layoffs percentage >100% or negative numbers).
7. Final Verification
After cleaning, performed checks to confirm:
	1.	No duplicates remain
	2.	No missing values in critical columns
	3.	All data types are correctly assigned

# Exploratory Data Analysis (EDA)
After cleaning the dataset, I performed an *Exploratory Data Analysis (EDA)* to find trends and insights.
# Key Insights:
- *Total layoffs by industry:* The most affected industries were Technology, Finance, and Retail.
- *Layoffs trend over time:* The highest number of layoffs occurred in 2023.
- *Countries with most layoffs:* The USA, India, and the UK were the most affected.
- *Top 10 companies with the most layoffs:* Companies like Meta, Amazon, and Google had the highest layoffs.

# Files Included
# layoffs_raw.csv (Unclean Data)
- Original dataset before cleaning, containing inconsistencies and missing values.
# layoffs_cleaned.csv (Final Cleaned Data)
- Fully cleaned and formatted dataset, ready for analysis.
# layoffs_cleaned.sql (Cleaned Data in SQL Format)
- SQL file that can be imported directly into MySQL.
# layoffs_eda (Explaratory Data Analysis)
# How to Use This Project
1. Clone this repository.  
2. Import layoffs_cleaned.csv into SQL or Excel for analysis.  
3. Use layoffs_cleaning.sql to clean any new/raw layoffs data.  

