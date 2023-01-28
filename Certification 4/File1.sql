use role sysadmin ;

-- creat a database
create database ZENAS_ATHLEISURE_DB ;
-- drop public schema
drop schema public;
-- create products schema
create schema PRODUCTS;


show stages ;
-- create a stage pointing to the uni-klaus
create stage UNI_KLAUS
url = 's3://uni-klaus';

list @UNI_KLAUS;
-- create a stage pointing to the uni-klaus/clothing
create stage UNI_KLAUS_CLOTHING
url = 's3://uni-klaus/clothing';

list @UNI_KLAUS_CLOTHING;

-- create a stage pointing to the uni-klaus/sneakers
create stage UNI_KLAUS_SNEAKERS
url = 's3://uni-klaus/sneakers';

list @UNI_KLAUS_SNEAKERS;

-- create a stage pointing to the uni-klaus/zenas_metadata and call it UNI_KLAUS_ZMD
create stage UNI_KLAUS_ZMD
url = 's3://uni-klaus/zenas_metadata';

list @UNI_KLAUS_ZMD;

-- 🥋 Query Data in Just One File at a Time , without loading the data
select $1
from @uni_klaus_zmd/product_coordination_suggestions.txt;


-- Testing out third theory
create  or replace file format zmd_file_format_3
FIELD_DELIMITER = '='
RECORD_DELIMITER = '^'
TRIM_SPACE = TRUE;

select $1, $2
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);


-- 🥋 Create an Exploratory File Format 
create or replace file format zmd_file_format_1
RECORD_DELIMITER = ';'
;

-- 🥋 Use the Exploratory File Format in a Query
select $1 as sizes_available
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1);


-- File format 2 for swt_product_line
create or replace file format zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER = ';'
TRIM_SPACE = TRUE;

select $1, $2, $3
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2);



-- 🥋 Use the replace function to eliminate the combination of Carriage Return and Line Feed Character  
select 
    REPLACE($1,chr(13)||chr(10)) as sizes_available
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1)
where sizes_available  <> ''
;
-- creating a sweatsuit_sizes view 
create  view zenas_athleisure_db.products.sweatsuit_sizes as 
select 
    REPLACE($1,chr(13)||chr(10)) as sizes_available
from @uni_klaus_zmd/sweatsuit_sizes.txt
(file_format => zmd_file_format_1)
where sizes_available  <> ''
;

select * from zenas_athleisure_db.products.sweatsuit_sizes;


-- creating SWEATBAND_PRODUCT_LINE

select 
    replace($1,chr(13)||chr(10)), 
    replace($2,chr(13)||chr(10)), 
    $3
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2);

create view zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE as 
select 
    replace($1,chr(13)||chr(10)) as PRODUCT_CODE, 
    replace($2,chr(13)||chr(10)) as HEADBAND_DESCRIPTION, 
    $3 AS WRISTBAND_DESCRIPTION
from @uni_klaus_zmd/swt_product_line.txt
(file_format => zmd_file_format_2);


-- creating view -> SWEATBAND_COORDINATION
create view zenas_athleisure_db.products.SWEATBAND_COORDINATION as 
select 
    replace($1, chr(13)||chr(10)) as PRODUCT_CODE,
    $2 as HAS_MATCHING_SWEATSUIT
from @uni_klaus_zmd/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);

-- Lesson 4 
list @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

select $1
from @ZENAS_ATHLEISURE_DB.PRODUCTS.UNI_KLAUS_CLOTHING;

select $1
from @uni_klaus_clothing/90s_tracksuit.png; 

-- query with 2 built-in meta-data columns
select metadata$filename, count(metadata$file_row_number) as NUMBER_OF_ROWS
from @uni_klaus_clothing
group by 1 
;


-- 🥋 Enabling, Refreshing and Querying Directory Tables 
--Directory Tables
select * from directory(@uni_klaus_clothing);

-- Oh Yeah! We have to turn them on, first
alter stage uni_klaus_clothing 
set directory = (enable = true);

--Now?
select * from directory(@uni_klaus_clothing);

--Oh Yeah! Then we have to refresh the directory table!
alter stage uni_klaus_clothing refresh;

--Now?
select * from directory(@uni_klaus_clothing);


-- Checking whether functions work on Directory tables
-- testing UPPER and REPLACE functions on directory table
select
 REPLACE(REPLACE(REPLACE(UPPER(RELATIVE_PATH),'/'),'_',' '),'.PNG') as product_name
from directory(@uni_klaus_clothing);


--  Can you Join Directory Tables with Other Tables? 
-- 🥋 Create an Internal Table in the Zena Database

--create an internal table for some sweat suit info
create or replace TABLE ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS (
	COLOR_OR_STYLE VARCHAR(25),
	DIRECT_URL VARCHAR(200),
	PRICE NUMBER(5,2)
);

--fill the new table with some data
insert into  ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUITS 
          (COLOR_OR_STYLE, DIRECT_URL, PRICE)
values
('90s', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/90s_tracksuit.png',500)
,('Burgundy', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/burgundy_sweatsuit.png',65)
,('Charcoal Grey', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/charcoal_grey_sweatsuit.png',65)
,('Forest Green', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/forest_green_sweatsuit.png',65)
,('Navy Blue', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/navy_blue_sweatsuit.png',65)
,('Orange', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/orange_sweatsuit.png',65)
,('Pink', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/pink_sweatsuit.png',65)
,('Purple', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/purple_sweatsuit.png',65)
,('Red', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/red_sweatsuit.png',65)
,('Royal Blue',	'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/royal_blue_sweatsuit.png',65)
,('Yellow', 'https://uni-klaus.s3.us-west-2.amazonaws.com/clothing/yellow_sweatsuit.png',65);

--create view catalog as 

create or replace  view catalog as 
select color_or_style
, direct_url
, price
, size as image_size
, last_modified as image_last_modified
, sizes_available
from sweatsuits s
join directory(@uni_klaus_clothing) d
on d.relative_path = SUBSTR(s.direct_url,54,50)
cross join sweatsuit_sizes;

select * from catalog;

-- 🥋 Add the Upsell Table and Populate It

-- Add a table to map the sweat suits to the sweat band sets
create table ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING
(
SWEATSUIT_COLOR_OR_STYLE varchar(25)
,UPSELL_PRODUCT_CODE varchar(10)
);

--populate the upsell table
insert into ZENAS_ATHLEISURE_DB.PRODUCTS.UPSELL_MAPPING
(
SWEATSUIT_COLOR_OR_STYLE
,UPSELL_PRODUCT_CODE 
)
VALUES
('Charcoal Grey','SWT_GRY')
,('Forest Green','SWT_FGN')
,('Orange','SWT_ORG')
,('Pink', 'SWT_PNK')
,('Red','SWT_RED')
,('Yellow', 'SWT_YLW');

-- 🥋 Zena's View for the Athleisure Web Catalog Prototype

-- Zena needs a single view she can query for her website prototype
create view catalog_for_website as 
select color_or_style
,price
,direct_url
,size_list
,coalesce('BONUS: ' ||  headband_description || ' & ' || wristband_description, 'Consider White, Black or Grey Sweat Accessories')  as upsell_product_desc
from
(   select color_or_style, price, direct_url, image_last_modified,image_size
    ,listagg(sizes_available, ' | ') within group (order by sizes_available) as size_list
    from catalog
    group by color_or_style, price, direct_url, image_last_modified, image_size
) c
left join upsell_mapping u
on u.sweatsuit_color_or_style = c.color_or_style
left join sweatband_coordination sc
on sc.product_code = u.upsell_product_code
left join sweatband_product_line spl
on spl.product_code = sc.product_code
where price < 200 -- high priced items like vintage sweatsuits aren't a good fit for this website
and image_size < 1000000 -- large images need to be processed to a smaller size
;


-- Geospatial data 

-- creating stages to the location where there is geo spatial data
create stage trails_geojson
url = 's3://uni-lab-files-more/dlkw/trails/trails_geojson' ; 

create stage trails_parquet
url = 's3://uni-lab-files-more/dlkw/trails/trails_parquet' ; 


-- creating JSON file format
create file format FF_JSON 
TYPE = 'JSON';
-- Creating PARQUET file format
create file format FF_PARQUET
TYPE = 'PARQUET';