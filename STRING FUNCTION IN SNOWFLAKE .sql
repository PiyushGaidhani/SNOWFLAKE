USE DATABASE DEMO_DATABASE;

CREATE OR REPLACE TABLE AGENTS
   (	
     AGENT_CODE CHAR(6) NOT NULL PRIMARY KEY, 
	 AGENT_NAME CHAR(40) , 
	 WORKING_AREA CHAR(35), 
	 COMMISSION NUMBER(10,2) DEFAULT 0.05, 
	 PHONE_NO CHAR(15), 
	 COUNTRY VARCHAR2(25) 
	 );

INSERT INTO AGENTS VALUES ('A007', 'Ramasundar', 'Bangalore',0.15,'077-25814763', '');
INSERT INTO AGENTS(AGENT_CODE,AGENT_NAME,WORKING_AREA) 
VALUES ('A110', 'Anand', 'Germany');


INSERT INTO AGENTS VALUES ('A003', 'Alex ', 'London', '0.13', '075-12458969', '');
INSERT INTO AGENTS VALUES ('A008', 'Alford', 'New York', '0.12', '044-25874365', '');
INSERT INTO AGENTS VALUES ('A011', 'Ravi Kumar', 'Bangalore', '0.15', '077-45625874', '');
INSERT INTO AGENTS VALUES ('A010', 'Santakumar', 'Chennai', '0.14', '007-22388644', '');
INSERT INTO AGENTS VALUES ('A012', 'Lucida', 'San Jose', '0.12', '044-52981425', '');
INSERT INTO AGENTS VALUES ('A005', 'Anderson', 'Brisban', '0.13', '045-21447739', '');
INSERT INTO AGENTS VALUES ('A001', 'Subbarao', 'Bangalore', '0.14', '077-12346674', '');
INSERT INTO AGENTS VALUES ('A002', 'Mukesh', 'Mumbai', '0.11', '029-12358964', '');
INSERT INTO AGENTS VALUES ('A006', 'McDen', 'London', '0.15', '078-22255588', '');
INSERT INTO AGENTS VALUES ('A004', 'Ivan', 'Torento', '0.15', '008-22544166', '');
INSERT INTO AGENTS VALUES ('A009', 'Benjamin', 'Hampshair', '0.11', '008-22536178', '');

SELECT * FROM AGENTS;

UPDATE AGENTS
SET COUNTRY='IN' WHERE COUNTRY='' OR COUNTRY IS NULL;

SELECT SUBSTRING('PIYUSH GAUDHANI', -7,-1); ---- NOT OUTPUT
SELECT SUBSTRING('PIYUSH GAIDHANI', 1,6);

SELECT SUBSTRING(AGENT_CODE,2,3) AS AGENT_NO FROM AGENTS; -- TO EXTRACT AGENT NO FROM AGENT CODE 

-- TO EXTRACT THE LENGTH OF THE STRING 
SELECT LEN('PIYUSH GAIDHANI')AS MY_NAME_LENGTH; 
SELECT SUBSTR('PIYUSH GAIDHANI',1,1)||SUBSTR('PIYUSH GAIDHANI',8,1)AS INITIALS; -- CONCAT FUNCTION WAY 1
SELECT CONCAT( SUBSTR('PIYUSH GAIDHANI',1,1),SUBSTR('PIYUSH GAIDHANI',8,1))AS INITIALS; --- CONCAT Way 2
 DESCRIBE TABLE AJ_CONSUMER_COMPLAINTS;
 SELECT * FROM AJ_CONSUMER_COMPLAINTS;


-- CREATE A VIEW WITH NOT NULL VALUES AND CONCAT ZIP CODE AND STATE NAME 

CREATE OR REPLACE VIEW CONSUMER_COMPLAINT_VIEW AS
SELECT *, CONCAT(STATE_NAME,'-',ZIP_CODE) AS ZIP_DETAILS
FROM AJ_CONSUMER_COMPLAINTS
WHERE SUB_ISSUE IS NOT NULL AND CONSUMER_COMPLAINT_NARRATIVE IS NOT NULL 
AND COMPANY_PUBLIC_RESPONSE IS NOT NULL AND TAGS IS NOT NULL ;


SELECT * FROM CONSUMER_COMPLAINT_VIEW;

CREATE OR REPLACE VIEW CONSUMER_COMPLAINT_DEMO_VIEW AS 
SELECT DATE_RECEIVED,PRODUCT_NAME,SUB_PRODUCT,ISSUE,COMPANY,CONCAT(STATE_NAME,'-',ZIP_CODE) AS ZIP_DETAILS,SUBMITTED_VIA,COMPANY_RESPONSE_TO_CONSUMER,
       TIMELY_RESPONSE,CONSUMER_DISPUTED,COMPLAINT_ID
FROM AJ_CONSUMER_COMPLAINTS;

SELECT * FROM CONSUMER_COMPLAINT_DEMO_VIEW;





/* To get a specific substring from an expression or string. 
You can also use the substring function if you want to get the substrings in reverse order from the strings. */

-- If you use the substrings in reverse order, use the starting index as a negative value.
select AGENT_CODE,AGENT_NAME,substring(AGENT_NAME,-3,3) AS NAME_BACKWARDS from agents;

/*
Snowflake CAST is a data-type conversion command. 
Snowflake CAST works similarly to the TO_ datatype conversion functions. 
If a particular data type conversion is not possible,
it raises an error. Let’s understand the Snowflake CAST in detail via the syntax and a few examples.
*/

SELECT CAST (177.86553628 AS DECIMAL(5,2));
SELECT CAST (177.86553628 AS DECIMAL(4,2)); -- IT WILL THROW A ERROR AS WE ARE WE ARE COMMANDING ONLY 4 TOTAL DIGITS IN TOTAL THAT MANIPUYLATES THE ORIGINAL VALUE 
                                             -- Number out of representable range: type FIXED[SB2](4,2){not null}, value 177.86553628               
select '1.6845'::decimal(2,1);
SELECT CAST('25-AUG-2021' AS TIMESTAMP);

-- When the provided precision is insufficient 
-- to hold the input value, the Snowflake CAST command raises an error as follows:
select cast('123.12' as number(4,2));
--Here, precision is set as 4 but the input value has a total of 5 digits, thereby raising the error.
select cast('123.12' as number(4,1));

--TRY_CAST( <source_string_expr> AS <target_data_type> )
select try_cast('05-Mar-2016' as timestamp);
--The Snowflake TRY_CAST command returns NULL as the input value 
--has more characters than the provided precision in the target data type.
select try_cast('PIYUSH' as char(4));

select cast ('27-09-2012' as timestamp); -- IT THROWS ERROR AS SNOWFLAKE ONLY ACCEPTS DATE FORMAT IN YYYY-MM-DD
SELECT CAST('2012-09-27' AS TIMESTAMP); ---- LIKE THIS WORKS 


--trim function
select trim('❄-❄ABC-❄-', '❄-') as trimmed_string;
select trim('❄-❄ABC-❄-', '❄') as trimmed_string;
select trim('❄-❄ABC-❄-', '-') as trimmed_string;
SELECT TRIM('********T E S T I N G 1 2 3 4********','*') AS TRIMMED_SPACE;
SELECT TRIM('********T E S T I*N*G 1 2 3 4********','*') AS TRIMMED_SPACE;

SELECT TRIM('#######-ABC-########','#-') AS TRIMMED_STRING;

-- LTRIM
SELECT LTRIM('#######-ABC-########','#-') AS TRIMMED_STRING; --- RIMS LEFT SIDE OF THE STRING 
SELECT LTRIM('       PIYUSH GAIDHANI',' ') AS TRIM_LEADING_SPACES;

--RTRIM
select rtrim('$125.00', '0.');
select rtrim('ANAND JHA*****', '*');

--To remove the white spaces or the blank spaces from the string TRIM function can be used. 
--It can remove the whitespaces from the start and end both.
select TRIM('  Snowflake Space Remove  ', ' ');
--To remove the first character from the string you can pass the string in the RTRIM function.
select LTRIM('Snowflake Remove  ', 'S'); --EXCEL U WILL FIND LEFT
--To remove the last character from the string you can pass the string in the RTRIM function.
select RTRIM('Snowflake Remove  ', 'e'); --IN EXCEL U WILL FIND RIGHT
--LENGTH FUNCTION
SELECT LEN(trim('  Snowflake Space Remove  ')) as length_EXCUDING_SPACE_string;
SELECT LENGTH(trim('  Snowflake Space Remove  ')) as length_string;

-- CONCAT 
SELECT * FROM AGENTS ;
SELECT CONCAT('KA','-','INDIA') AS COUNTRY_CODE;

SELECT*, CONCAT('*',AGENT_CODE,'-',AGENT_NAME,'*')AS  AGENT_DETAILS FROM AGENTS;


--Snowflake CONCAT_WS Function
/* The concat_ws function concatenates two or more strings or concatenates two or more binary values 
and adds a separator between those strings.
The CONCAT_WS operator requires at least two arguments and uses the first argument to separate all following arguments
Following is the concat_ws function syntax
CONCAT_WS( <separator> , <expression1> [ , <expressionN> ... ] ) */

SELECT CONCAT_WS('-', 'KA','India') as state_country; Following is the concat_ws function syntax
CONCAT_WS( <separator> , <expression1> [ , <expressionN> ... ] ) */

SELECT CONCAT_WS('-', 'KA','India') as state_country;

/*
Snowflake Concat Operator (||)
The concatenation operator concatenates two strings on either side of the || symbol and returns the concatenated string. 
The || operator provides an alternative syntax for CONCAT and requires at least two arguments.

For example,
*/
select 'Nested' || ' CONCAT' || ' example!' as Concat_operator;


--Handling NULL Values in the CONCAT function and the Concatenation operator
--For both the CONCAT function and the concatenation operator,
--if one or both strings are null, the result of the concatenation is null.
--For example,

select concat('Bangalore, ', NULL) as null_example; -- IF WE CONCAT  NULL WALUES THEN THE OUTPUT WILL BE NULL
select 'Bangalore, '|| NULL as null_example;

--REVERSE A STRING 
SELECT REVERSE ('INDIA IS MY COUNTRY');

SELECT REVERSE ('YRTNUOC YM SI AIDNI');

--SPLIT FUNCTION

SELECT SPLIT'127.80.90','.');
SELECT SPLIT('ANAND-KUMAR-JHA',' ');
SELECT SPLIT('ANAND-KUMAR-JHA','-');
select split('|a||', '|');

create or replace table aj_persons
(
   NAME CHAR(10),
   CHILDREN VARCHAR(30)
);

INSERT INTO AJ_PERSONS
VALUES('Mark','Marky,Mark Jr,Maria'),('John','Johnny,Jane');
SELECT * FROM AJ_PERSONS
;
SELECT SPLIT(CHILDREN ,',') FROM AJ_PERSONS;

select name, PIYUSH.value::string as childname
from AJ_persons,
     lateral flatten(input=>split(children, ',')) PIYUSH;


select  split_part('11.22.33', '.', 1) as first_part , 
        split_part('11.22.33', '.', 2) as sec_part;


select split_part('aaa--bbb-BBB--ccc', '--',1);
select split_part('aaa--bbb-BBB--ccc', '--',2);
select split_part('aaa--bbb-BBB--ccc', '--',3);
select split_part('aaa--bbb-BBB--ccc', '--',-1);

SELECT split(AGENT_DETAILS, '-') AS SPLIT_RECORDS
FROM (
SELECT *,concat(AGENT_CODE, '-', AGENT_NAME) AS agent_details 
  from agents );

  
SELECT lower('India Is My Country') as lwr_strng;
SELECT UPPER('India Is My Country') as upr_strng;


select UPPER(CONCAT(substring('ruhee k qureshi',1,1), 
                    substring('ruhee k qureshi',7,1) ,
                    substring('ruhee k qureshi',9,1))) as initial;

SELECT INITCAP('india is my country') as init_cap_sent;
/*
delimiters specified as an empty string (i.e. '') instructs INITCAP to ignore all delimiters, 
including whitespace characters, in the input expression (i.e. the input expression is treated as a single, continuous word). 
The resulting output is a string with the 
first character capitalized (if the first character is a letter) and all other letters in lowercase.
*/
select initcap('this is the new Frame+work');
select initcap('this is the new Framework','');
select initcap('iqamqinterestedqinqthisqtopic','q');
select initcap('lion☂fRog☂potato⨊cLoUD', 


--REPLACE COMMAND
-- REPLACE( <subject> , <pattern> [ , <replacement> ] )

select REPLACE( '   ANAND KUMAR JHA   ' ,' ','*');
select REPLACE( '   ANAND KUMAR JHA   ' ,' '); -- 
SELECT LEN( REPLACE('PIYUSH    ',' '));

create or replace table replace_example
(subject varchar(10), 
 pattern varchar(10), 
 replacement varchar(10));
 
insert into replace_example 
values('snowman', 'snow', 'fire'), 
('sad face', 'sad', 'happy');
SELECT * FROM REPLACE_EXAMPLE;


select subject, pattern, replacement, 
       replace(subject, pattern, replacement) as new 
       from replace_example;



select * from AJ_CONSUMER_COMPLAINTS WHERE STARTSWITH(PRODUCT_NAME,'Bank');
select * from AJ_CONSUMER_COMPLAINTS WHERE PRODUCT_NAME LIKE '%Bank';
select * from AJ_CONSUMER_COMPLAINTS where contains(PRODUCT_NAME, 'Bank');
select * from AJ_CONSUMER_COMPLAINTS where endswith(PRODUCT_NAME , 'Loan');


































