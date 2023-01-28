-- Creating a database with Sysadmin role 
USE ROLE SYSADMIN;
CREATE DATABASE INTL_DB
comment = 'Created INTL_DB'
;
USE SCHEMA INTL_DB.PUBLIC;
-- Creating a warehouse 
CREATE WAREHOUSE INTL_WH 
WITH WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 600 
AUTO_RESUME = TRUE;

USE WAREHOUSE INTL_WH;

--  Create Table INT_STDS_ORG_3661
CREATE OR REPLACE TABLE INTL_DB.PUBLIC.INT_STDS_ORG_3661 
(ISO_COUNTRY_NAME varchar(100), 
 COUNTRY_NAME_OFFICIAL varchar(200), 
 SOVEREIGNTY varchar(40), 
 ALPHA_CODE_2DIGIT varchar(2), 
 ALPHA_CODE_3DIGIT varchar(3), 
 NUMERIC_COUNTRY_CODE integer,
 ISO_SUBDIVISION varchar(15), 
 INTERNET_DOMAIN_CODE varchar(10)
);

-- Create a File Format to Load the Table
CREATE OR REPLACE FILE FORMAT INTL_DB.PUBLIC.PIPE_DBLQUOTE_HEADER_CR 
  TYPE = 'CSV' 
  COMPRESSION = 'AUTO' 
  FIELD_DELIMITER = '|' 
  RECORD_DELIMITER = '\r' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '\042' 
  TRIM_SPACE = FALSE 
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
  ESCAPE = 'NONE' 
  ESCAPE_UNENCLOSED_FIELD = '\134'
  DATE_FORMAT = 'AUTO' 
  TIMESTAMP_FORMAT = 'AUTO' 
  NULL_IF = ('\\N');
  
  
  
  create stage demo_db.public.like_a_window_into_an_s3_bucket
url = 's3://uni-lab-files';

-- listing all the files
list @demo_db.public.like_a_window_into_an_s3_bucket;

-- copying data from external stage (file is nested inside a folder) to a table
copy into INTL_DB.PUBLIC.INT_STDS_ORG_3661
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ( 'smew/ISO_Countries_UTF8_pipe.csv')
file_format = ( format_name='PIPE_DBLQUOTE_HEADER_CR' );


-- data check
SELECT count(*) as FOUND, '249' as EXPECTED 
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661; 

-- Does a table with that name exist...in a certain schema...within a certain database.
select count(*) as OBJECTS_FOUND
from INTL_DB.INFORMATION_SCHEMA.TABLES
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3661';

-- checking row count using INFORMATION_SCHEMA tables 
select row_count
from INTL_DB.INFORMATION_SCHEMA.TABLES
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3661';


SELECT  
    iso_country_name
    , country_name_official,alpha_code_2digit
    ,r_name as region
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661 i
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
ON UPPER(i.iso_country_name)=n.n_name
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
ON n_regionkey = r_regionkey;

-- creating a view 
CREATE VIEW NATIONS_SAMPLE_PLUS_ISO 
( iso_country_name
  ,country_name_official
  ,alpha_code_2digit
  ,region) AS
  
  
SELECT  
    iso_country_name
    , country_name_official,alpha_code_2digit
    ,r_name as region
FROM INTL_DB.PUBLIC.INT_STDS_ORG_3661 i
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
ON UPPER(i.iso_country_name)=n.n_name
LEFT JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
ON n_regionkey = r_regionkey
;
-- checking data in the view 
SELECT *
FROM INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO;

/*Loading data from stage to table*/
-- creating CURRENCIES table
CREATE TABLE INTL_DB.PUBLIC.CURRENCIES 
(
  CURRENCY_ID INTEGER, 
  CURRENCY_CHAR_CODE varchar(3), 
  CURRENCY_SYMBOL varchar(4), 
  CURRENCY_DIGITAL_CODE varchar(3), 
  CURRENCY_DIGITAL_NAME varchar(30)
)
  COMMENT = 'Information about currencies including character codes, symbols, digital codes, etc.';
  -- creating COUNTRY_CODE_TO_CURRENCY_CODE table
  CREATE TABLE INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE 
  (
    COUNTRY_CHAR_CODE Varchar(3), 
    COUNTRY_NUMERIC_CODE INTEGER, 
    COUNTRY_NAME Varchar(100), 
    CURRENCY_NAME Varchar(100), 
    CURRENCY_CHAR_CODE Varchar(3), 
    CURRENCY_NUMERIC_CODE INTEGER
  ) 
  COMMENT = 'Many to many code lookup table';
  
  -- creating file format CSV_COMMA_LF_HEADER
  CREATE FILE FORMAT INTL_DB.PUBLIC.CSV_COMMA_LF_HEADER
  TYPE = 'CSV'
  COMPRESSION = 'AUTO' 
  FIELD_DELIMITER = ',' 
  RECORD_DELIMITER = '\n' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
  TRIM_SPACE = FALSE 
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
  ESCAPE = 'NONE' 
  ESCAPE_UNENCLOSED_FIELD = '\134' 
  DATE_FORMAT = 'AUTO' 
  TIMESTAMP_FORMAT = 'AUTO' 
  NULL_IF = ('\\N');
  
-- list all the files in an external stage 
list @demo_db.public.like_a_window_into_an_s3_bucket;
-- loading to currencies table from external stage
copy into INTL_DB.PUBLIC.CURRENCIES
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ( 'smew/currencies.csv')
file_format = ( format_name='CSV_COMMA_LF_HEADER' );

-- loading to COUNTRY_CODE_TO_CURRENCY_CODE table from external stage
copy into INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE
from @demo_db.public.like_a_window_into_an_s3_bucket
files = ( 'smew/country_code_to_currency_code.csv')
file_format = ( format_name='CSV_COMMA_LF_HEADER' );

-- creating a view based on INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE
create view SIMPLE_CURRENCY AS 
select 
    COUNTRY_CHAR_CODE as CTY_CODE,
    CURRENCY_CHAR_CODE as CUR_CODE
from INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE ;




use role accountadmin;
grant override share restrictions on account to role accountadmin;

ALTER VIEW INTL_DB.PUBLIC.NATIONS_SAMPLE_PLUS_ISO
SET SECURE; 

ALTER VIEW INTL_DB.PUBLIC.SIMPLE_CURRENCY
SET SECURE;

SHOW MANAGED ACCOUNTS;
