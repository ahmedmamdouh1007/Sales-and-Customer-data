

-----------------STEP 1:-->EXPLORE DATA---------------
SELECT * 
FROM sales_data;

SELECT * 
FROM customer_data;

--EXPLORE NAN DATA--
SELECT *
FROM customer_data
WHERE age IS NULL

--REPLACE NAN DATA WITH AVERAGE AGE --
UPDATE customer_data
	SET age=( 
			SELECT AVG(AGE)
			FROM customer_data)
	WHERE age IS NULL

--UNDURSTANDING DATE DATA--
SELECT DISTINCT date
FROM sales_data
ORDER BY 1

--DUPLICATE DATA--

SELECT customer_id , COUNT(*) AS C
FROM customer_data
GROUP BY customer_id
HAVING COUNT(*) > 1


SELECT customer_id , COUNT(*) AS C
FROM sales_data
GROUP BY customer_id
HAVING COUNT(*) > 1

--OUTLIER DATA--
WITH TABLE2 AS (
	SELECT 
		AVG(price) AS mean, 
		STDEV(price) AS std
	FROM sales_data
)

SELECT S.price, ((S.price - T.mean) / T.std) AS Zscore
FROM sales_data S
CROSS JOIN TABLE2 T
WHERE ((S.price - T.mean) / T.std) > 2 OR ((S.price - T.mean) / T.std) < -2;

WITH TABLE2 AS (
	SELECT 
		AVG(price) AS mean, 
		STDEV(price) AS std
	FROM sales_data 
)

UPDATE sales_data
SET price = T.mean
FROM TABLE2 T
CROSS JOIN sales_data S
WHERE ((S.price - T.mean) / T.std) > 2;

--NO HAVE ILLOGICAL DATES OR FUTURE DATES--

---------------------STEP 2:--> ANALYSIS DATA--------------------

                             -------Q1: ANALYSIS PRICES BY BRANCHS---------
 SELECT Branch, SUM(price) AS TotalSAles
 FROM sales_data
 GROUP BY Branch
 ORDER BY TotalSAles DESC;

 --After knowing the two best-selling branches so far,
 --we identify the factors that affect the increase in sales to determine a suitable strategy for the rest of the branches---
  
  --GENDER--
SELECT C.gender, S.Branch, SUM(S.price) AS TotalSales
FROM sales_data S
JOIN customer_data C
ON S.customer_id = C.customer_id
GROUP BY C.gender, S.Branch
ORDER BY TotalSales DESC;

--(BY Mall of Istanbul)--
SELECT gender, Branch, SUM(TotalSales) AS TotalSales
FROM (
	  SELECT C.gender, S.Branch, SUM(S.price) AS TotalSales
	  FROM sales_data S
	  JOIN customer_data C
	  ON S.customer_id = C.customer_id
	  GROUP BY C.gender, S.Branch
) AS TAPLE1
WHERE Branch = 'Mall of Istanbul'
GROUP BY gender, Branch
ORDER BY TotalSales DESC;
--So one of the strategies we can follow is to focus on products for female, but to be sure,
--we need to make sure which products to focus on and whether they are specific to female.
SELECT C.gender, S.[Product Type],S.Branch, SUM(S.price) AS TotalSales
		  FROM sales_data S
		  JOIN customer_data C
		  ON S.customer_id = C.customer_id
		  GROUP BY C.gender, S.[Product Type], S.Branch
		  ORDER BY 4 DESC;


SELECT gender, [Product Type], SUM(TotalSales) AS TotalSales
FROM(
	SELECT C.gender, S.[Product Type], S.Branch, SUM(S.price) AS TotalSales
		  FROM sales_data S
		  JOIN customer_data C
		  ON S.customer_id = C.customer_id
		  GROUP BY C.gender, S.Branch, S.[Product Type]
		 
	) AS TABLE2

WHERE gender = 'Female'
GROUP BY gender, [Product Type]
ORDER BY TotalSales DESC;
---In the first question,
---we identified the best-selling branches, and from there we were able to know the effect of gender on sales,
---and it turned out that women buy more than men and for clothes in particular,
---so we recommend increasing the focus on clothes in the rest of the branches.


                             
							 -------Q2: Analyze age groups and their impact on sales.---------
SELECT C.age, SUM(S.price) AS TotalSales
	FROM sales_data S
	JOIN customer_data C
	ON 
	S.customer_id = C.customer_id
	GROUP BY C.age
	ORDER BY TotalSales
	

						   	        --We divide ages into categories for ease of use
                                           --18-25 ,26-35, 36-45, 46-60, 60+
SELECT SUM(S.price) AS TotalSales,
        CASE 
            WHEN C.age BETWEEN 18 AND 25 THEN '18-25'
            WHEN C.age BETWEEN 26 AND 35 THEN '26-35'
            WHEN C.age BETWEEN 36 AND 45 THEN '36-45'
            WHEN C.age BETWEEN 46 AND 60 THEN '46-60'
            ELSE '60+'
        END AS AGES
	FROM sales_data S
	JOIN customer_data C
	ON 
	S.customer_id = C.customer_id
	GROUP BY C.age



SELECT 
    AGES, 
    SUM(TotalSales) AS TotalSales
FROM (
    SELECT SUM(S.price) AS TotalSales,
        CASE 
            WHEN C.age BETWEEN 18 AND 25 THEN '18-25'
            WHEN C.age BETWEEN 26 AND 35 THEN '26-35'
            WHEN C.age BETWEEN 36 AND 45 THEN '36-45'
            WHEN C.age BETWEEN 46 AND 60 THEN '46-60'
            ELSE '60+'
        END AS AGES
	FROM sales_data S
	JOIN customer_data C
	ON 
	S.customer_id = C.customer_id
	GROUP BY C.age
) AS TABLE3
GROUP BY AGES
ORDER BY TotalSales;
--We see a variety of purchases, but the youngest group is the one that buys the most.



							 -------Q3: Is there a seasonal effect on sales.---------
SELECT YEAR(date) AS YEAR, SUM(price) AS TotalSales
FROM sales_data
GROUP BY YEAR(date)
ORDER BY TotalSales DESC;
--We noticed the dramatic change in sales during the third year

SELECT YEAR(date) AS YEAR, Branch, SUM(price) AS TotalSales
FROM sales_data
GROUP BY YEAR(date), Branch
ORDER BY 1 ;


                       --To better understand the data, please go to the visualizations section--
	  https://app.powerbi.com/links/I99OPqjHjN?ctid=1158e2d5-dc24-41ad-abce-62841076dbde&pbi_source=linkShare














