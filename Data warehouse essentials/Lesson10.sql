// Create an Ingestion Table for XML Data
CREATE TABLE LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML 
(
  "RAW_AUTHOR" VARIANT
);

//Create File Format for XML Data
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.XML_FILE_FORMAT 
TYPE = 'XML' 
STRIP_OUTER_ELEMENT = FALSE 
; 

show stages; 
list @garden_plants.veggies.LIKE_A_WINDOW_INTO_AN_S3_BUCKET/author;



copy into LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML
from @like_a_window_into_an_s3_bucket
files = ('author_with_header.xml')
file_format = (format_name = LIBRARY_CARD_CATALOG.PUBLIC.XML_FILE_FORMAT)
FORCE = TRUE;

select * from LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML;


copy into LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML
from @like_a_window_into_an_s3_bucket
files = ('author_no_header.xml')
file_format = (format_name = LIBRARY_CARD_CATALOG.PUBLIC.XML_FILE_FORMAT)
FORCE = TRUE;

select * from LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML;

//MODIFY File Format for XML Data by Changing Config

CREATE OR REPLACE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.XML_FILE_FORMAT 
TYPE = 'XML' 
COMPRESSION = 'AUTO' 
PRESERVE_SPACE = FALSE 
STRIP_OUTER_ELEMENT = TRUE 
DISABLE_SNOWFLAKE_DATA = FALSE 
DISABLE_AUTO_CONVERT = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

truncate LIBRARY_CARD_CATALOG.PUBLIC.AUTHOR_INGEST_XML;



-- Selecting the XML data
//Returns entire record
SELECT raw_author 
FROM author_ingest_xml;

// Presents a kind of meta-data view of the data
SELECT raw_author:"$" 
FROM author_ingest_xml; 

//shows the root or top-level object name of each row
SELECT raw_author:"@" 
FROM author_ingest_xml; 

//returns AUTHOR_UID value from top-level object's attribute
SELECT raw_author:"@AUTHOR_UID"
FROM author_ingest_xml;

//returns value of NESTED OBJECT called FIRST_NAME
SELECT XMLGET(raw_author, 'FIRST_NAME'):"$"
FROM author_ingest_xml;

//returns the data in a way that makes it look like a normalized table
SELECT 
raw_author:"@AUTHOR_UID" as AUTHOR_ID
,XMLGET(raw_author, 'FIRST_NAME'):"$" as FIRST_NAME
,typeof(XMLGET(raw_author, 'FIRST_NAME'):"$") as type_of_the_prev_column
,XMLGET(raw_author, 'MIDDLE_NAME'):"$" as MIDDLE_NAME
,XMLGET(raw_author, 'LAST_NAME'):"$" as LAST_NAME
FROM AUTHOR_INGEST_XML;

//add ::STRING to cast the values into strings and get rid of the quotes
SELECT 
raw_author:"@AUTHOR_UID" as AUTHOR_ID
,XMLGET(raw_author, 'FIRST_NAME'):"$"::STRING as FIRST_NAME
--,typeof(XMLGET(raw_author, 'FIRST_NAME'):"$") as type_of_prev_column
,XMLGET(raw_author, 'MIDDLE_NAME'):"$"::STRING as MIDDLE_NAME
,XMLGET(raw_author, 'LAST_NAME'):"$"::STRING as LAST_NAME
FROM AUTHOR_INGEST_XML; 


// JSON DDL Scripts
USE LIBRARY_CARD_CATALOG;

// Create an Ingestion Table for JSON Data
CREATE TABLE "LIBRARY_CARD_CATALOG"."PUBLIC"."AUTHOR_INGEST_JSON" 
(
  "RAW_AUTHOR" variant
);


//Create File Format for JSON Data
CREATE FILE FORMAT LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE
STRIP_NULL_VALUES = FALSE
IGNORE_UTF8_ERRORS = FALSE; 

copy into library_card_catalog.public.author_ingest_json
from @garden_plants.veggies.LIKE_A_WINDOW_INTO_AN_S3_BUCKET
files = ('author_with_header.json')
file_format = (format_name = LIBRARY_CARD_CATALOG.PUBLIC.JSON_FILE_FORMAT)
force = TRUE;

select raw_author from library_card_catalog.public.author_ingest_json;

select raw_author:AUTHOR_UID from author_ingest_json;

//returns AUTHOR_UID value from top-level object's attribute
select raw_author:AUTHOR_UID
from author_ingest_json;

//returns the data in a way that makes it look like a normalized table
SELECT 
 raw_author:AUTHOR_UID
,raw_author:FIRST_NAME::STRING as FIRST_NAME
,raw_author:MIDDLE_NAME::STRING as MIDDLE_NAME
,raw_author:LAST_NAME::STRING as LAST_NAME
FROM AUTHOR_INGEST_JSON;