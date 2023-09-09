USE DEMO_DATABASE;

create or replace table songs_history
(
history_id	integer,
user_id	integer,
song_id	integer,
song_plays	integer);

INSERT INTO songs_history
VALUES (10011,777,1238,11),(1245,695,4520,1);

SELECT * FROM songs_history;

CREATE OR REPLACE TABLE songs_weekly
(
user_id	integer,
song_id	integer,
listen_time	datetime);

INSERT INTO songs_weekly
VALUES 
(777,1238,'08/01/2022 12:00:00'),
(695,4520,'08/04/2022 08:00:00'),
(125,9630,'08/04/2022 16:00:00'),
(695,4520,'08/07/2022 12:00:00');

SELECT * FROM songs_weekly;

/*
Goal: Output the user id, song id and cumulative count of the song plays as of 4 August 2022.

Find the count of song plays by the user and song.
Combine the output with the historical streaming data.
Obtain the user id, song id and cumulative count of the song plays.
We’re using song plays and streaming interchangeably, but it should mean the same.

Step 1: Find the count of song plays by the user and song

According to the assumptions, the weekly table holds streaming data from 1 August 2022 to 7 August 2022. 
Since the question asks for data up to 4 August 2022 (inclusive), we have to filter to the specified date.

*/

SELECT USER_ID, COUNT(SONG_ID)
FROM SONGS_WEEKLY
WHERE DATE(listen_time)<='08/04/2022 16:00:00'
GROUP BY 1;

-- COMBINE THE OUTPUT WITH HISTORICAL STREAMING DATA 

SELECT USER_ID,SONG_ID,SONG_PLAYS FROM SONGS_HISTORY
UNION 
SELECT USER_ID,SONG_ID,COUNT(SONG_ID) AS SONG_PLAYS
FROM SONGS_WEEKLY
WHERE DATE(LISTEN_TIME)<='08/07/2022 12:00:00'
GROUP BY 1,2;

/* The trick for a UNION/UNION ALL to work is:

The number and the order of the fields in SELECT for both queries must be the same.
The data types must be compatible. */

--Step 3: Obtain the user id, song id and cumulative count of the song plays
-- Now that we have a table containing the historical streaming data up to 4 August 2022, 
-- let's work on the final step: 
-- Find the cumulative count of song plays and order them in descending order.
SELECT USER_ID,SONG_ID,SUM(SONG_PLAYS)AS SONG_COUNT
FROM (SELECT USER_ID,SONG_ID,SONG_PLAYS FROM SONGS_HISTORY
UNION 
SELECT USER_ID,SONG_ID,COUNT(SONG_ID) AS SONG_PLAYS
FROM SONGS_WEEKLY
WHERE DATE(LISTEN_TIME)<='08/07/2022 12:00:00'
GROUP BY 1,2) AS REPORT
GROUP BY 1,2
ORDER BY 3 DESC;
-------------------------------------------------------------------QUESTION 2 --------------------------------------------------------------------------------

create or replace table transactions 
(transaction_id	integer,
account_id	integer,
transaction_type	varchar,
amount	decimal);

INSERT INTO transactions
VALUES(123,101,'Deposit',10.00),
(124,101,'Deposit',20.00),
(125,101,'Withdrawal',5.00),
(126,201,'Deposit',20.00),
(128,201,'Withdrawal',10.00);

--SOLUTION : KEY CONCEPTS : CASE STATEMENTS 
/* We can determine whether money is deposited or withdrawn with the transaction_type column using a 
CASE WHEN statement and modifying the values of the amount column accordingly.

Let's negate the withdrawn amounts (-1 * amount) and leave the deposited amounts as they are: */

-- Now, we can calculate the ending balance by calculating the SUM of the modified amounts.
-- We'll GROUP BY the account_id so that the sums (which represent the final balances) 
-- will be calculated for each account separately.

-- FINAL BALANCE OF EACH ACCOUNT 
SELECT * FROM transactions;
SELECT account_id,
SUM(CASE WHEN TRANSACTION_TYPE ='Deposit' THEN AMOUNT
     ELSE -AMOUNT 
     END) AS FINAL_BALANCE
     FROM TRANSACTIONS
GROUP BY 1;

SELECT ACCOUNT_ID,
(CASE WHEN TRANSACTION_TYPE = 'Deposit' THEN AMOUNT 
ELSE -AMOUNT
END )AS balance
FROM TRANSACTIONS;



DROP TABLE TRANSACTIONS;

-------------------------------------------------------------------QUESTION 5 --------------------------------------------------------------------------------
CREATE OR REPLACE TABLE transactions 
(
transaction_id	integer,
type	string,
amount	decimal,
transaction_date	timestamp
);

INSERT INTO transactions
VALUES (19153,'deposit',65.90,'07/10/2022 10:00:00'),
       (53151,'deposit',178.55,'07/08/2022 10:00:00'),
       (29776,'withdrawal',25.90,'07/08/2022 10:00:00'),
       (16461,'withdrawal',45.99,'07/08/2022 10:00:00'),
       (77134,'deposit',32.60,'07/10/2022 10:00:00');
       
SELECT * FROM transactions;

/*
------ Solution
To start off, it is much easier if we start to solve the problem from the end - 
i.e. we want to have daily cumulative balances that reset every month.
Thus, to obtain two different granularities of transaction_date column 
we can utilize DATE_TRUNC function.

In order to obtain balances instead of solely transaction values, 
we can use CASE to assign positive sign to deposit and negative to withdrawals,
and then just sum and group the values on a daily level 
(there might be multiple transactions during the day).

As the next step, we utilize SUM with a window function and calculate the sum partitioning 
by month - this makes sure that the cumulative sum is set to zero each month.
*/

SELECT TRANSACTION_DAY,
SUM(BALANCE) OVER(PARTITION BY TRANSACTION_MONTH ORDER BY TRANSACTION_DAY) AS BALANCE
FROM (select 
date_trunc('day',transaction_date) as TRANSACTION_DAY,
DATE_TRUNC('MONTH',transaction_date) AS TRANSACTION_MONTH,
SUM(CASE
    WHEN TYPE = 'deposit'THEN AMOUNT
        ELSE -AMOUNT
        END) AS BALANCE
FROM TRANSACTIONS
GROUP BY 1,2)
ORDER BY 1;