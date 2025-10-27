🧹 Data Cleaning in MySQL – Layoffs Dataset

📖 Project Overview

This project focuses on cleaning and transforming a layoffs dataset using MySQL.
The goal was to identify and fix inconsistencies, handle missing values, remove duplicates, and make the data ready for Exploratory Data Analysis (EDA).

🗂️ Dataset Information

Dataset Name: layoffs.csv

Imported Table: layoffs

Cleaned Table: layoffs_staging2

🧩 Data Cleaning Process
1️⃣ Create a Staging Table

To ensure the original data stays safe, a staging table was created and populated:

CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;

2️⃣ Remove Duplicates

Used CTE and ROW_NUMBER() to identify and remove duplicate rows:

WITH duplicates_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
             PARTITION BY company, location, total_laid_off, percentage_laid_off, date
           ) AS row_num
    FROM layoffs_staging
)
DELETE FROM duplicates_cte WHERE row_num > 1;

3️⃣ Standardize Data

Removed extra spaces using TRIM()

Fixed inconsistent values (e.g., Crypto Currency → CryptoCurrency)

Converted date formats into proper DATE type

UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%Y-%m-%d');

4️⃣ Handle Missing or Null Values

Checked and filled missing or blank fields:

SELECT * 
FROM layoffs_staging2 
WHERE industry IS NULL OR industry = '';

5️⃣ Remove Unnecessary Columns
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;

📊 Final Cleaned Table
company	location	industry	total_laid_off	percentage_laid_off	date	stage	country	funds_raised_millions

This table is now clean, standardized, and ready for further analysis or visualization.

⚙️ Tools & Technologies Used

🐬 MySQL Workbench

📂 CSV Dataset

💻 GitHub for version control

🧠 Key Learnings

✨ Practiced SQL data cleaning using functions like TRIM(), REPLACE(), and STR_TO_DATE()
✨ Learned to use CTE and window functions for duplicates removal
✨ Understood how to structure a real-world SQL cleaning workflow

🚀 How to Run the Project

Import your dataset into MySQL Workbench

Run each SQL command step by step in your editor

Verify cleaned data using:

SELECT * FROM layoffs_staging2;

🌸 Author
Omika Gupta
🎓 Engineering Student at Chandigarh University
💻 Passionate about Data Analytics, SQL, and Web Development
