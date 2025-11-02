-- Data Cleaning (Project 1)
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

-- Exploratory Data Analysis (Project 2)
SELECT *
FROM layoffs_staging2;

 SELECT MAX(total_laid_off) AS MAX_TOTAL_LAID ,MIN(total_laid_off) as MIN_TOTAL_LAID, MAX(percentage_laid_off) AS MAX_PERCENTAGE_LAID ,MIN(percentage_laid_off) as MIN_PERCENTAGE_LAID
 FROM layoffs_staging2;
 
 SELECT company,SUM(total_laid_off) as sum_total
 FROM layoffs_staging2
  WHERE company IS NOT NULL 
  group by company
  order by 2 DESC 
;
 SELECT  company,YEAR(`date`),SUM(total_laid_off) as sum_total
 FROM layoffs_staging2
  WHERE YEAR(`date`) IS NOT NULL 
  group by company,YEAR(`date`)
  order by 2 ASC, 3 DESC
;
 SELECT  company,SUBSTRING(`date`,1,7) AS Date,SUM(total_laid_off) as sum_total
 FROM layoffs_staging2
  WHERE company IS NOT NULL 
  group by company,country,SUBSTRING(`date`,1,7)
  order by 2 DESC, 3 DESC
;
 SELECT  company,country,SUBSTRING(`date`,1,7) AS Date,SUM(total_laid_off) as sum_total
 FROM layoffs_staging2
  WHERE company IS NOT NULL 
  group by company,country,SUBSTRING(`date`,1,7)
  order by 2 ASC,3 ASC, 4 DESC
;
 
WITH CTE_ROLLING AS
(
    SELECT 
        SUBSTRING(`date`,1,7) AS `Month`,
        SUM(total_laid_off) AS sum_total
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL
    GROUP BY `Month`
    ORDER BY 1 ASC
)
SELECT 
    `Month`, 
    sum_total,
    SUM(sum_total) OVER(ORDER BY `Month`) AS rolling_total
FROM CTE_ROLLING
;

WITH COMPANY_YEAR (company,years,total_laid_off) AS 
(
SELECT company,YEAR(`date`),SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
),
COMPANY_YEAR_RANK AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS RANK_S
FROM COMPANY_YEAR
WHERE years IS NOT NULL
ORDER BY RANK_S
)
SELECT *
FROM COMPANY_YEAR_RANK
WHERE RANK_S <= 5;

--  Exploratory Data Analysis END 
