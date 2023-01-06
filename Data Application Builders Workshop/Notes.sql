/*Dora setup testing*/
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DORA_IS_WORKING' as step
 ,(select 223) as actual
 , 223 as expected
 ,'Dora is working!' as description
); 

/*Dora DABW01*/
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW01' as step
 ,(select count(*) 
   from PC_RIVERY_DB.INFORMATION_SCHEMA.SCHEMATA 
   where schema_name ='PUBLIC') as actual
 , 1 as expected
 ,'Rivery is set up' as description
);
/*Dora DABW02*/
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DABW02' as step
 ,(select count(*) 
   from PC_RIVERY_DB.INFORMATION_SCHEMA.TABLES 
   where ((table_name ilike '%FORM%') 
   and (table_name ilike '%RESULT%'))) as actual
 , 1 as expected
 ,'Rivery form results table is set up' as description
);
/*Dora DABW03*/
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW03' as step
 ,(select sum(round(nutritions_sugar)) 
   from PC_RIVERY_DB.PUBLIC.FRUITYVICE) as actual
 , 35 as expected
 ,'Fruityvice table is perfectly loaded' as description
);
/*Dora DABW04*/
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW04' as step
 ,(select count(*) 
   from pc_rivery_db.public.fdc_food_ingest
   where lowercasedescription like '%cheddar%') as actual
 , 50 as expected
 ,'FDC_FOOD_INGEST Cheddar 50' as description
);
/*Dora DABW05*/
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW05' as step
 ,(select count(*) 
   from pc_rivery_db.public.fdc_food_ingest) as actual
 , 927 as expected
 ,'All the fruits!' as description
);
/*Dora DABW06*/
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW06' as step
 ,(select count(distinct METADATA$FILENAME) 
   from @demo_db.public.my_internal_named_stage) as actual
 , 3 as expected
 ,'I PUT 3 files!' as description
);
/*Dora DABW07*/
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
   SELECT 'DABW07' as step 
   ,(select count(*) 
     from pc_rivery_db.public.fruit_load_list 
     where fruit_name in ('jackfruit','papaya', 'kiwi', 'test', 'from streamlit', 'guava')) as actual 
   , 4 as expected 
   ,'Followed challenge lab directions' as description
); 


-- Resuming after a week from lesson 8
select * from pc_rivery_db.public.fdc_food_ingest;

/*Cloning 303 rows from the table*/
create table pc_rivery_db.public.fdc_food_ingest_303_clone clone pc_rivery_db.public.fdc_food_ingest;
select count(1) from pc_rivery_db.public.fdc_food_ingest_303_clone;
/*Recreating the original table from the 303 clone*/
-- drop table pc_rivery_db.public.fdc_food_ingest;
-- create table pc_rivery_db.public.fdc_food_ingest clone pc_rivery_db.public.fdc_food_ingest_303_clone;

/*Creating FRUIT_LOAD_LIST table*/
create table  pc_rivery_db.public.FRUIT_LOAD_LIST (
    FRUIT_NAME varchar(25)
);
/*Inserting 10 rows into it*/
insert into pc_rivery_db.public.fruit_load_list
values 
('banana')
,('cherry')
,('strawberry')
,('pineapple')
,('apple')
,('mango')
,('coconut')
,('plum')
,('avocado')
,('starfruit');

/*show all the stages in the account*/
show stages in account;

/*creating internal stage*/
create stage DEMO_DB.PUBLIC.my_internal_named_stage;

/*Upload the files to the internal stage using a put command*/

/*Use a LIST command to view a list of files in your Named Internal Stage*/
list @my_internal_named_stage;

select $1 from @my_internal_named_stage/File2.txt.gz;

/*Cleaning up the fruit load list table*/
select * from pc_rivery_db.public.fruit_load_list;

delete from pc_rivery_db.public.fruit_load_list 
where fruit_name like 'from streamlit';

select * from 
PC_RIVERY_DB.PUBLIC.HEALTHY_FOOD_INTEREST_FORM_RESULTS_INGEST;

select * from 
PC_RIVERY_DB.PUBLIC.FRUITYVICE;

select count(1) from 
PC_RIVERY_DB.PUBLIC.FDC_FOOD_INGEST;

alter table PC_RIVERY_DB.PUBLIC.FDC_FOOD_INGEST rename to PC_RIVERY_DB.PUBLIC.FDC_FOOD_INGEST_CHEDDAR;
--create table PC_RIVERY_DB.PUBLIC.FDC_FOOD_INGEST as 
select * from PC_RIVERY_DB.PUBLIC.FDC_FOOD_INGEST_CHEDDAR
where 1 = 0;
select * from PC_RIVERY_DB.PUBLIC.FDC_FOOD_INGEST where lower(description) like '%guava%';
select count(1) from PC_RIVERY_DB.PUBLIC.FDC_FOOD_INGEST;
select * from INFORMATION_SCHEMA ;
SHOW COLUMNs;