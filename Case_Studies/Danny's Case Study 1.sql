CREATE DATABASE TESTING3;
USE TESTING3;

CREATE OR REPLACE TABLE sales (
 customer_id VARCHAR(1),
 order_date DATE,
  product_id INT);
  
INSERT INTO sales
VALUES
('A', '2021-01-01', '1'),
('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),
('A', '2021-01-10', '3'),
('A', '2021-01-11', '3'),
('A', '2021-01-11', '3'),
('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),
('B', '2021-01-04', '1'),
('B', '2021-01-11', '1'),
('B', '2021-01-16', '3'),
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3');  

CREATE OR REPLACE TABLE menu (
product_id INT,
product_name VARCHAR(5),
price INT
);

INSERT INTO menu
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  
 CREATE OR REPLACE TABLE members (
  customer_id VARCHAR(1),
   join_date DATE); 

INSERT INTO members
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
SELECT * FROM  sales;
SELECT * FROM menu;
SELECT * FROM members;


--Case Study----

--1. What is the total amount each customer spent at the restaurant?
SELECT S.CUSTOMER_ID,SUM(M.PRICE) AS TOTAL_PRICE 
FROM SALES AS S 
JOIN MENU AS M ON S.PRODUCT_ID=M.PRODUCT_ID
GROUP BY 1;

--2. How many days has each customer visited the restaurant?
SELECT CUSTOMER_ID,COUNT(DISTINCT ORDER_DATE) AS DAYS_VISITED
FROM SALES
GROUP BY 1;

-- What was the first item from the menu purchased by each customer?

SELECT S.CUSTOMER_ID,M.PRODUCT_NAME 
FROM SALES AS S 
JOIN MENU AS M USING (PRODUCT_ID)
WHERE S.ORDER_DATE IN(SELECT MIN(ORDER_DATE)
                      FROM SALES GROUP BY CUSTOMER_ID); 

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?--
SELECT M.PRODUCT_NAME,S.PRODUCT_ID, COUNT(S.PRODUCT_ID) AS PURCHASE_FREQUENCY
FROM MENU AS M 
JOIN SALES AS S USING(PRODUCT_ID)
GROUP BY 1,2
ORDER BY S.PRODUCT_ID DESC;

--5. Which item was the most popular for each customer?
WITH cust_pop AS(
SELECT CUSTOMER_ID,PRODUCT_ID,COUNT(PRODUCT_ID) AS ORDER_COUNT
FROM SALES 
GROUP BY 1,2)

SELECT CUSTOMER_ID,PRODUCT_NAME 
FROM (SELECT C.CUSTOMER_ID,M.PRODUCT_NAME ,
 DENSE_RANK()OVER (PARTITION BY C.CUSTOMER_ID ORDER BY C.ORDER_COUNT DESC)AS RANK
 FROM cust_pop C
 JOIN MENU AS M USING(PRODUCT_ID)) AS CUST_FAV
 WHERE RANK = 1;

 /*SELECT S.CUSTOMER_ID,M.PRODUCT_NAME,
 DENSE_RANK()OVER(PARTITION BY S.CUSTOMER_ID ORDER BY COUNT(PRODUCT_ID) DESC) AS RANK
 FROM SALES AS S
 WHERE RANK =1
 JOIN MENU AS M USING (PRODUCT_ID)
 GROUP BY 1,2;*/

 -- Which item was purchased first by the customer after they became a member?
 WITH AFTER_JOIN  AS (
  SELECT S.*,MBR.JOIN_DATE,M.PRODUCT_NAME,
  FIRST_VALUE(ORDER_DATE)OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE) AS AFTER_JOIN_ORDER,
  RANK()OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE) AS RANK 
  FROM SALES AS S 
  JOIN MENU AS M USING(PRODUCT_ID)
  JOIN MEMBERS AS MBR USING (CUSTOMER_ID)
  WHERE S.ORDER_DATE>=JOIN_DATE
 ) 
 SELECT CUSTOMER_ID,PRODUCT_NAME
 FROM AFTER_JOIN 
 WHERE RANK = 1 ;
 -- WE CAN USE FIRST VALUE TO EXTRACT THE FIRST ORDER BUT WITH THIS WE ARE NOT ABLE TO OBTIAIN THE RANK AS FIRST VALUE OF EVERY ORDER DATE IS DATE SO WE ADTIONALLY HAVE TO USE RANK FUNCTION FOR RANKING THE ROWS TO GET THE DESIRED OUTPUT 
-- TO OVER COME THIS PROBLEM WE CAN DO 
WITH AFTER_JOIN AS (
SELECT S.*,M.PRODUCT_NAME,
DENSE_RANK()OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE)AS FIRST_ORDER
FROM SALES AS S 
JOIN MEMBERS AS MBR USING(S.CUSTOMER_ID)
JOIN MENU AS M ON S.PRODUCT_ID = M.PRODUCT_ID
WHERE S.ORDER_DATE>=MBR.JOIN_DATE
)
SELECT CUSTOMER_ID,PRODUCT_NAME
FROM AFTER_JOIN
WHERE FIRST_ORDER = 1;

 ---7. Which item was purchased just before the customer became a member?
 WITH LAST_ORDER_MEMBER AS (
SELECT S.*,M.PRODUCT_NAME,
DENSE_RANK()OVER(PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE DESC)AS LAST_ORDER
FROM SALES AS S 
JOIN MEMBERS AS MBR USING(S.CUSTOMER_ID)
JOIN MENU AS M ON S.PRODUCT_ID = M.PRODUCT_ID
WHERE S.ORDER_DATE<MBR.JOIN_DATE
)
SELECT CUSTOMER_ID,PRODUCT_NAME 
FROM LAST_ORDER_MEMBER
WHERE LAST_ORDER=1;

--8. What is the total items and amount spent for each member before they became a member?


 SELECT S.CUSTOMER_ID , 
 SUM(M.PRICE) AS TOTAL_SPENT,
 COUNT(S.PRODUCT_ID) AS TOTAL_ITEMS 
 FROM SALES AS S
 JOIN MEMBERS AS MBR USING(S.CUSTOMER_ID)
 JOIN MENU AS M ON S.PRODUCT_ID = M.PRODUCT_ID 
 WHERE S.ORDER_DATE<MBR.JOIN_DATE
 GROUP BY 1;

 --9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier how many points would each customer have?
 WITH CUST_POINTS AS (
 SELECT S. CUSTOMER_ID,M.PRODUCT_NAME,
 CASE WHEN M.PRODUCT_NAME ='sushi' THEN PRICE*20
      ELSE PRICE*10
 END AS POINTS
 FROM SALES AS S
 JOIN MENU AS M USING (PRODUCT_ID))

 SELECT CUSTOMER_ID,SUM(POINTS) AS TOTAL_POINTS
 FROM CUST_POINTS
 GROUP BY 1;

 --10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
--how many points do customer A and B have at the end of January?
WITH CUST_POINTS AS (
SELECT S.CUSTOMER_ID,M.PRODUCT_NAME,
DATEADD(DAY,'6',MBR.JOIN_DATE) AS END_PROMO,
M.PRODUCT_ID,MBR.JOIN_DATE,M.PRICE,
CASE 
WHEN S.PRODUCT_ID=1 THEN M.PRICE*20
WHEN S.PRODUCT_ID!=1 AND (S.ORDER_DATE BETWEEN MBR.JOIN_DATE AND DATEADD(DAY,'6',MBR.JOIN_DATE))
     THEN M.PRICE*20
ELSE M.PRICE*10
END AS POINTS
FROM SALES AS S
JOIN MEMBERS AS MBR USING (S.CUSTOMER_ID)
JOIN MENU AS M ON S.PRODUCT_ID = M.PRODUCT_ID
WHERE S.ORDER_DATE<='2021-01-31')

SELECT CUSTOMER_ID,SUM(POINTS) AS TOTAL_POINTS
FROM CUST_POINTS
GROUP BY 1;

--------------JOIN ALL TABLES---------------------
 SELECT S.CUSTOMER_ID,S.ORDER_DATE,M.PRODUCT_NAME,M.PRICE,
 CASE WHEN S.ORDER_DATE < MBR.JOIN_DATE THEN 'N'
 WHEN S.ORDER_DATE>=MBR.JOIN_DATE THEN 'Y'
 ELSE 'N'
 END AS MEMBER
 FROM SALES AS S
 JOIN MENU AS M USING (PRODUCT_ID)
 LEFT JOIN MEMBERS AS MBR USING(CUSTOMER_ID);

 


 

