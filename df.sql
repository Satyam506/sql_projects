CREATE VIEW forestation AS
SELECT fs.country_code ccode, fs.country_name country, fs.year year_stamp, fs.forest_area_sqkm
forest_area,ar.total_area_sq_mi total_area,
rg.region region, rg.income_group income,100.0*(fs.forest_area_sqkm / (ar.total_area_sq_mi * 2.59)) AS
percentage
FROM forest_area fs, land_area ar, regions rg
WHERE (fs.country_code = ar.country_code AND fs.year = ar.year AND rg.country_code =
ar.country_code);
SELECT * FROM forestation;


SELECT *
FROM forest_area
WHERE country_name = 'World'
AND (year = 2016 OR year = 1990);


SELECT present.forest_area_sqkm - previous.forest_area_sqkm AS difference
FROM forest_area AS present
JOIN forest_area AS previous
ON (present.year = '2016' AND previous.year = '1990'
AND present.country_name = 'World' AND previous.country_name = 'World');


SELECT
100.0*(present.forest_area_sqkm - previous.forest_area_sqkm) /
previous.forest_area_sqkm AS percentage
FROM forest_area AS present
JOIN forest_area AS previous
ON (present.year = '2016' AND previous.year = '1990' AND present.country_name = 'World' AND
previous.country_name = 'World');


SELECT country, (total_area_sq_mi * 2.59) AS total_area_sqkm
FROM forestation
WHERE year = 2016
ORDER BY total_area_sqkm;



SELECT percentage
FROM forestation
WHERE year = 2016
AND country = 'World';


SELECT *
FROM forestation
WHERE year = 1990
AND country = 'World';


SELECT ROUND(CAST((region_forest_1990/ region_area_1990) * 100 AS NUMERIC), 2)
AS forest_percent_1990,
ROUND(CAST((region_forest_2016 / region_area_2016) * 100 AS NUMERIC), 2)
AS forest_percent_2016,
region
FROM (SELECT SUM(fr.forest_area_sqkm) region_forest_1990,SUM(fr.total_area_sqkm) region_area_1990,
fr.region,SUM(fr1.forest_area_sqkm) region_forest_2016,
SUM(fr1.total_area_sqkm) region_area_2016
FROM forestation fr, forestation fr1
WHERE fr.year = '1990'
AND fr.country != 'World'
AND fr1.year = '2016'
AND fr1.country != 'World'
AND fr.region = fr1.region
GROUP BY fr.region) region_percent
ORDER BY forest_percent_1990 DESC;


SELECT present.country_name,
present.forest_area_sqkm - previous.forest_area_sqkm AS difference
FROM forest_area AS present
JOIN forest_area AS previous
ON (present.year = '2016' AND previous.year = '1990') AND present.country_name =
previous.country_name
ORDER BY difference DESC;


SELECT present.country_name,
100.0*(present.forest_area_sqkm - previous.forest_area_sqkm) /
previous.forest_area_sqkm AS percentage
FROM forest_area AS present
JOIN forest_area AS previous
ON (present.year = '2016' AND previous.year = '1990') AND present.country_name =
previous.country_name
ORDER BY percentage DESC;


SELECT present.country_name,
present.forest_area_sqkm - previous.forest_area_sqkm AS difference
FROM forest_area AS present
JOIN forest_area AS previous
ON (present.year = '2016' AND previous.year = '1990') AND present.country_name =
previous.country_name
ORDER BY difference;


SELECT present.country_name,
100.0*(present.forest_area_sqkm - previous.forest_area_sqkm) /
previous.forest_area_sqkm AS percentage
FROM forest_area AS present
JOIN forest_area AS previous
ON (present.year = '2016' AND previous.year = '1990') AND present.country_name =
previous.country_name
ORDER BY percentage;


SELECT distinct(quartiles), COUNT(country) OVER (PARTITION BY quartiles)
FROM (SELECT country,
CASE WHEN percentage <= 25 THEN '0-25%'
WHEN percentage <= 75 AND percentage > 50 THEN '50-75%'
WHEN percentage <= 50 AND percentage > 25 THEN '25-50%'
ELSE '75-100%'
END AS quartiles FROM forestation
WHERE percentage IS NOT NULL AND year = 2016) quart;


SELECT country, percentage
FROM forestation
WHERE percentage > 75 AND year = 2016;


SELECT quartile.ntile, COUNT(ntile)
FROM (SELECT country, NTILE(4) OVER
(ORDER BY percentage)
FROM forestation
WHERE year = 2016) AS quartile;