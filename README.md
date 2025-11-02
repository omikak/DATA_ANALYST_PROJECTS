# Layoffs Data Cleaning — MySQL

**Project:** Data Cleaning & EDA Preparation for `layoffs.csv`
**Author:** Omika Gupta — Engineering Student, Chandigarh University

---

## 🚀 Project Summary

This repository documents a practical, repeatable MySQL workflow to clean and standardize a layoffs dataset so it's ready for Exploratory Data Analysis (EDA) and visualization.

The process preserves the original data, removes duplicates, fixes inconsistent values and formats, handles missing values, and produces a polished staging table called `layoffs_staging2`.

---

## 🗂 Dataset

* **Filename:** `layoffs.csv`
* **Imported table:** `layoffs`
* **Final cleaned table:** `layoffs_staging2`

**Final table columns:**

```
company | location | industry | total_laid_off | percentage_laid_off | date | stage | country | funds_raised_millions
```

---

## 🔧 Tools & Technologies

* MySQL / MySQL Workbench
* CSV (original dataset)
* Git / GitHub for version control

---

## 🧩 Cleaning Workflow (step-by-step)

Follow the steps below to reproduce the clean dataset.

### 1. Create a safe staging copy

Create a working copy so the original import remains unchanged.

```sql
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;
```

### 2. Remove exact duplicates using a window function

Use `ROW_NUMBER()` to identify duplicates and delete extras.

```sql
WITH duplicates_cte AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY company, location, total_laid_off, percentage_laid_off, date
         ) AS row_num
  FROM layoffs_staging
)
DELETE FROM duplicates_cte WHERE row_num > 1;
```

> Tip: Partition keys can be adapted if you want looser duplicate logic (e.g., ignoring `funds_raised_millions`).

### 3. Standardize text fields and tidy whitespace

Trim unwanted spaces and normalize inconsistent values.

```sql
UPDATE layoffs_staging
SET company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(REPLACE(industry, 'Crypto Currency', 'CryptoCurrency'));
```

### 4. Convert and standardize dates

Convert date strings into `DATE` type (adjust the format string if your source differs).

```sql
ALTER TABLE layoffs_staging
MODIFY COLUMN date VARCHAR(50); -- if needed, ensure it's convertible

UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%Y-%m-%d');

-- (Optional) Create a proper DATE column and migrate values
ALTER TABLE layoffs_staging
ADD COLUMN date_parsed DATE;

UPDATE layoffs_staging
SET date_parsed = STR_TO_DATE(date, '%Y-%m-%d');

-- Rename/cleanup as appropriate
```

### 5. Handle missing or blank values

Find rows with missing important fields and either fill or flag them.

```sql
SELECT * FROM layoffs_staging
WHERE industry IS NULL OR industry = '';

-- Example: backfill a missing industry with 'Unknown'
UPDATE layoffs_staging
SET industry = 'Unknown'
WHERE industry IS NULL OR industry = '';
```

### 6. Remove intermediate/unnecessary columns

If you created helper columns like `row_num` or temporary text fields, drop them.

```sql
ALTER TABLE layoffs_staging
DROP COLUMN row_num;
```

### 7. Save final cleaned table

Create the final cleaned table `layoffs_staging2` from your working staging table.

```sql
CREATE TABLE layoffs_staging2 AS
SELECT company, location, industry, total_laid_off, percentage_laid_off,
       COALESCE(date_parsed, STR_TO_DATE(date, '%Y-%m-%d')) AS date,
       stage, country, funds_raised_millions
FROM layoffs_staging;
```

---

## ✅ What Changed / Results

* Duplicates removed
* Leading/trailing whitespace trimmed
* Inconsistent industry labels standardized
* Dates converted to `DATE` type for reliable time-series analysis
* Missing `industry` values either flagged or filled (based on chosen strategy)
* Final polished table `layoffs_staging2` ready for EDA, aggregates, and visualizations

---

## 💡 Key Learnings

* Practical use of CTEs and `ROW_NUMBER()` for de-duplication
* Common string functions (`TRIM`, `REPLACE`) are essential for text normalization
* Importance of preserving raw data and working on a staging copy
* Converting to native types (DATE, INT, FLOAT) simplifies analysis downstream

---

## ▶ How to run this project (quick)

1. Open MySQL Workbench and import `layoffs.csv` into a table named `layoffs`.
2. Run the SQL statements above step-by-step in the Workbench SQL editor.
3. Inspect results with:

```sql
SELECT * FROM layoffs_staging2 LIMIT 100;
```

4. Use `GROUP BY`, window functions, or visualization tools for EDA.

---


---

## 🧾 License

Feel free to reuse this workflow for learning and non-commercial projects. Add a license file if you plan to publish.

---

## ✨ Author

**Omika Gupta** — Engineering Student at Chandigarh University
Passionate about Data Analytics, SQL, and Web Development

---
