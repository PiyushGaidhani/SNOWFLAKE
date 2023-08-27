--Add identity or autoincrement to table in Snowflake

/* In Snowflake, you can set the default value for a column, 
which is typically used to set an autoincrement or identity as the default value, 
so that each time a new row is inserted a unique id for that 
row is generated and stored and can be used as a primary key. 

You can specify the default value for a column using create table or alter table.

However, if you try to alter a table to add an autoincrement column that already 
has data in it, we will get an error in Snowflake. 

This is not supported in Snowflake, due to the underlying architecture.

It’s not as easy as altering the existing table, but there are two ways we can add an 
identity or autoincrement column to an existing table. */

--Method 1: Using autoincrement or identity as a default value.
--First we are going to create a simple table that we want to add an identity/autoincrement field to:

use database "DEMO_DATABASE";

create or replace table PG_COLORS as
    select name
    from (values ('blue'),('red'),('green')) colors (name);

describe table PG_COLORS;
select * from PG_COLORS;
    
-- Next we create a new table with the same structure as the existing table and add an idenity column.    
create or replace table pg_identity_column_example like PG_COLORS;

select * from pg_identity_column_example;




alter table pg_identity_column_example 
add column id int identity(1,3); --default value is 1 and it will increment by 3

insert into pg_identity_column_example(name) 
    select name from pg_colors;
    drop table pg_colors;
    
    select * from pg_identity_column_example;

/* The identity autoincrement columns take two optional parameters:
         -> start the starting value of the column
          -> increment the specific amount to increment each row
          
In the example above we set the column to start at 1 and increment by 3.

autoincrement and identity are synonymous with each other and the default value for start and increment, 
if not specified, is 1 for both*/

--To replace our existing colors table with the new table:
alter table PG_IDENTITY_COLUMN_EXAMPLE rename to colors;
drop table colors;

SELECT * FROM colors;

-- Method 2: Using sequences
/*
In the example above we only had one column, so specifying the column manually in the insert worked fine for our use case. 
But, sometimes existing tables have a lot of columns and we don’t want to have to specify each column, either to save time or also to avoid errors.

We can programatically add an autoincrement or identity field to a wide table, 
but we have to do it a little differently.
*/

-- The main problem here and the reason we get an error is when we use * 
-- the number of columns returned is one less than the new table we created. 
-- We can’t specify an empty value in a select statement, so we can’t force the identity column 
-- to populate in the way we want. 
-- We could specifiy the columns we want to populate manually, 
-- leaving out only the id column, but that’s what we are trying to avoid.


-- Let’s use an existing Snowflake sample data table to see why we can’t just alter the existing table:
-- FIRST STEP
create or replace table identity_column_example like "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER";
DESCRIBE TABLE identity_column_example;

-- generating sequences - SECOND STEP
CREATE OR REPLACE SEQUENCE PG_SEQ
start = 1
INCREMENT = 5
comment ='this seq will be used to generate employee IDs';

DESCRIBE SEQUENCE PG_SEQ;

--DONT IONSERT RECORDS AS AUTOINCREMENT WORKS ON EMPTY TABLE
--insert into  "DEMO_DATABASE"."PUBLIC"."IDENTITY_COLUMN_EXAMPLE"
---select * from "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER";

SELECT * FROM "IDENTITY_COLUMN_EXAMPLE";

--3RD STEP
alter table identity_column_example 
add column id int identity(1,1) ;

SELECT  * FROM identity_column_example;

-- Let’s see what happens when we fill that column with an expression that auto-increments.
-- 4TH STEP
insert into identity_column_example 
select *,row_number() over (order by null)
from "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER";

SELECT * FROM identity_column_example ORDER BY ID;


insert into identity_column_example(c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment)
values (219874, 'Customer#000219874', 'sadhjekj', 9, '19-505-461-2873', 999.99, 'asjdasgdj', 'sdadtyhkjer');

select * from identity_column_example WHERE c_custkey = '219874';
SELECT * FROM identity_column_example ORDER BY ID;

select * from identity_column_example 
order by id 
limit 3;

-- As you can see we have a duplicate value in our id field, 
--because the identity column counter was never triggered, 
--- so when we insert a new record it starts over at 1.

--In this case, we have to use a sequence. The identity and autoincrement default values use 
---sequences under the hood, 
-- so we will be essentially recreating that functionality.

-- When we create our own sequence we have access to the next value in the sequence. 
-- This allows us to add the next incremental value when we backfill the new table with the old table.

-- First, we create a sequence that starts at 1 and increments by 1 and name it seq1:
create or replace sequence seq1 start=1 increment=1;

DESCRIBE SEQUENCE seq1;

create or replace sequence seq2 start=100 increment=1;

--Next, we’ll recreate our table and add a column id with the nextval of the seq1 sequence as the default:
create or replace table identity_column_example like "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER";

select get_ddl('table', 'identity_column_example');

--ADDING COLUMNS ID
alter table identity_column_example 
add column id int DEFAULT seq1.NEXTVAL;

--SYNTAX : alter table <table-name> ADD/modify column <column-name> default <new-sequence-name>.nextval;

-- Remove the default value
--alter table <table-name> modify column <column-name> drop default;

alter table identity_column_example MODIFY COLUMN id  DEFAULT seq2.NEXTVAL; 

--Then, we can backfill the new table using nextval:
insert into identity_column_example 
select *,seq2.nextval from "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."CUSTOMER";

-- Now, when we add a new record, the id column autoincrements properly and will remain unique:
insert into identity_column_example(c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment)
values (219874, 'Customer#000219874', 'sadhjekj', 9, '19-505-461-2873', 999.99, 'asjdasgdj', 'sdadtyhkjer');

select * from identity_column_example 
--where c_custkey = 219874;
order by id;





















--SYNTAX : alter table <table-name> modify column <column-name> default <new-sequence-name>.nextval;
alter table identity_column_example MODIFY COLUMN id  DEFAULT seq1.NEXTVAL;





UPDATE table identity_column_example 
SET id  default seq1.nextvalue;

































    