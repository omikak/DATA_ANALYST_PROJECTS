-- Data Cleaning
SELECT *
FROM layoffs;
-- 1. Remove Duplicates if any
 -- 2. Standarized Data
 -- 3. Look for null or blank values
 -- 4. Remove unnecessary columns if any
 
 -- STARTING OF PART 1
 CREATE TABLE layoffs_staging
 LIKE layoffs;
 INSERT INTO  layoffs_staging
 SELECT *
 FROM layoffs;
 
 WITH DUPLICATES_CTE AS
(
SELECT *,
ROW_NUMBER() OVER ( PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
) AS row_num
FROM 
layoffs_staging
)
SELECT *
FROM DUPLICATES_CTE
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num`	INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM layoffs_staging;
    
    DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >1;

SELECT *
from layoffs_staging2;
 
-- END OF PART 1
 
 -- STARTING OF PART 2 
 SELECT DISTINCT industry
 FROM layoffs_staging2
 ORDER BY 1;
 
 UPDATE layoffs_staging2
 SET company=TRIM(company)
 ;
  SELECT DISTINCT industry
 FROM layoffs_staging2
 WHERE industry LIKE 'Crypto%';
 
 UPDATE layoffs_staging2
 SET industry = 'Crypto'
 WHERE industry LIKE 'Crypto%';
 
 SELECT DISTINCT industry
 FROM  
 layoffs_staging2
 ORDER BY 1;
 
 UPDATE layoffs_staging2
 SET country = TRIM(TRAILING '.' FROM country)
 WHERE country LIKE 'United States%';
 
 UPDATE layoffs_staging2
  SET `date` = STR_TO_DATE(`date`,"%Y-%m-%d");
  
  -- ALWAYS ALTER STAGING TABLE NEVER EVER MODIFY RAW DATA TABLE

  ALTER TABLE layoffs_staging2
  MODIFY COLUMN `date` DATE;
  
-- END OF PART 2

-- STARTING OF PART 3
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company=t2.company 
AND t1.location=t2.location
SET t1.industry =t2.industry
WHERE t1.industry IS NULL;

-- END OF PART 3

-- STARTING OF PART 4
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
 
 DELETE 
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
 
 ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

 -- END OF PART 4

 
 

