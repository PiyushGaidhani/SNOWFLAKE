USE DATABASE DEMO_DATABASE;

CREATE OR REPLACE TABLE PG_COMPLAIN
(
 ID	INT ,
 ComplainDate VARCHAR(10),
 CompletionDate	VARCHAR(10),
 CustomerID	INT,
 BrokerID	INT,
 ProductID	INT,
 ComplainPriorityID	INT,
 ComplainTypeID	INT,
 ComplainSourceID	INT,
 ComplainCategoryID	INT,
 ComplainStatusID	INT,DEMO_DATABASE.PUBLIC
 AdministratorID	STRING,
 ClientSatisfaction	VARCHAR(20),
 ExpectedReimbursement INT
);
ALTER TABLE PG_COMPLAIN  
ADD  PRIMARY KEY (ID);

select * from PG_COMPLAIN;

select distinct * from PG_COMPLAIN; --13,846
---------------------------------------------------------------------------------------------------------


CREATE OR REPLACE TABLE PG_CUSTOMER
(
CustomerID	INT,
LastName VARCHAR(60),
FirstName VARCHAR(60),
BirthDate VARCHAR(20) ,
Gender VARCHAR(20),
ParticipantType	VARCHAR(20),
RegionID	INT,
MaritalStatus VARCHAR(15));
ALTER TABLE PG_CUSTOMER
ADD PRIMARY KEY (CustomerID);

select distinct * from PG_customer;--12,305
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PG_BROKER
(
  BrokerID	INT,
  BrokerCode VARCHAR(70),
  BrokerFullName	VARCHAR(60),
  DistributionNetwork	VARCHAR(60),
  DistributionChannel	VARCHAR(60),
  CommissionScheme VARCHAR(50)

);
ALTER TABLE PG_BROKER
ADD PRIMARY KEY (BrokerID);

select * from PG_BROKER; --707
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PG_CATAGORIES
(
ID	INT,
Description_Categories VARCHAR2(200),
Active INT
);
ALTER TABLE PG_CATAGORIES
ADD PRIMARY KEY (ID);

select * from PG_CATAGORIES; --56 rows
---------------------------------------------------------------------------------------------------------

CREATE OR REPLACE TABLE PG_PRIORITIES
(
ID	INT,
Description_Priorities VARCHAR(10)
);
ALTER TABLE PG_PRIORITIES
ADD PRIMARY KEY (ID);

select * from PG_PRIORITIES; --2 rows
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PG_PRODUCT
(
ProductID	INT,
ProductCategory	VARCHAR(60),
ProductSubCategory	VARCHAR(60),
Product VARCHAR(30)
);
ALTER TABLE PG_PRODUCT
ADD PRIMARY KEY (ProductID);
DESCRIBE TABLE  PG_PRODUCT;


select distinct * from PG_PRODUCT; -- 77rows
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PG_REGION
(
  id INT,
  name	VARCHAR(50) ,
  county	VARCHAR(100),
  state_code	CHAR(5),
  state	VARCHAR (60),
  type	VARCHAR(50),
  latitude	NUMBER(11,4),
  longitude	NUMBER(11,4),
  area_code	INT,
  population	INT,
  Households	INT,
  median_income	INT,
  land_area	INT,
  water_area	INT,
  time_zone VARCHAR(70)
);
ALTER TABLE PG_REGION
ADD PRIMARY KEY (id);

select distinct * from PG_REGION; --994 ROWS
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PG_SOURCES
(
ID	INT,
Description_Source VARCHAR(20)
);
ALTER TABLE PG_SOURCES
ADD PRIMARY KEY (ID);

select distinct * from PG_SOURCES; -- 9 rows
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PG_STATE_REGION
(
  State_Code VARCHAR(20),	
  State	 VARCHAR(20),
  Region VARCHAR(20)
);
ALTER TABLE PG_STATE_REGION
ADD PRIMARY KEY (State_Code);

select DISTINCT* from PG_STATE_REGION; --48 rows
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PG_STATUSES
(
  ID	INT,
  Description_Status VARCHAR(40));
  ALTER TABLE PG_STATUSES
  ADD PRIMARY KEY (ID);
  
  select * from PG_STATUSES; -- 7 rows
---------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PG_TYPE
(
  ID INT	,
  Description_Type VARCHAR(20)
);
ALTER TABLE PG_TYPE
ADD PRIMARY KEY (ID);

select * from PG_type; -- 10 rows

CREATE OR REPLACE TABLE PG_STATUS_HISTORY
(
   ID INT,
   ComplaintID	INT ,
   ComplaintStatusID INT,
   StatusDate VARCHAR(10)
);
ALTER TABLE PG_STATUS_HISTORY
ADD PRIMARY KEY (ID);

select * from PG_STATUS_HISTORY; --11,558
                                                     --COM.*,CUS.*,SH.*,REG.*,SR.*,BR.*,CAT.*,PRI.*,PR.*,SUR.*,ST.*,TY.*
CREATE OR REPLACE TABLE PG_CUST_MASTER AS 
SELECT COM.ID,COM.ComplainDate,COM.COMPLETIONDATE,CUS.FIRSTNAME,CUS.LASTNAME,CUS.BIRTHDATE,BR.BROKERCODE,
    BR.BROKERFULLNAME,BR.COMMISSIONSCHEME,REG.STATE,SR.REGION,PR.PRODUCT,PR.PRODUCTCATEGORY,PRODUCTSUBCATEGORY,
    PRI.DESCRIPTION_PRIORITIES,TY.DESCRIPTION_TYPE,SUR.DESCRIPTION_SOURCE,CAT.ACTIVE,CAT.DESCRIPTION_CATEGORIES,
    ST.DESCRIPTION_STATUS,SH.STATUSDATE
FROM PG_COMPLAIN  COM
LEFT OUTER JOIN PG_CUSTOMER  CUS ON  COM.CustomerID = CUS.CustomerID
LEFT OUTER JOIN PG_STATUS_HISTORY  SH ON COM.ID = SH.ID
LEFT OUTER JOIN PG_REGION  REG ON CUS.RegionID = REG.ID
LEFT OUTER JOIN PG_BROKER  BR ON COM.BrokerID = BR.BrokerID
LEFT OUTER JOIN PG_PRODUCT  PR ON COM.ProductID = PR.ProductID
LEFT OUTER JOIN PG_CATAGORIES  CAT ON COM.COMPLAINCATEGORYID = CAT.ID
LEFT OUTER JOIN PG_STATE_REGION SR ON REG.STATE_CODE = SR.STATE_CODE
LEFT OUTER JOIN PG_TYPE TY ON COM.COMPLAINTYPEID = TY.ID
LEFT OUTER JOIN PG_SOURCES AS SUR ON COM.COMPLAINSOURCEID = SUR.ID
LEFT OUTER JOIN PG_STATUSES AS ST ON COM.COMPLAINSTATUSID = ST.ID
LEFT OUTER JOIN PG_PRIORITIES AS PRI ON COM.COMPLAINPRIORITYID = PRI.ID ;

SELECT * FROM PG_CUST_MASTER;




