create stage garden_plants.veggies.like_a_window_into_an_s3_bucket 
 url = 's3://uni-lab-files';
 
 list @garden_plants.veggies.LIKE_A_WINDOW_INTO_AN_S3_BUCKET;
 list @LIKE_A_WINDOW_INTO_AN_S3_BUCKET;
 list @like_a_window_into_an_s3_bucket/this_;
 list @like_a_window_into_an_s3_bucket/THIS_;
 
 create or replace table vegetable_details_soil_type
( plant_name varchar(25)
 ,soil_type number(1,0)
);

desc file format PIPECOLSEP_ONEHEADROW;

copy into vegetable_details_soil_type
from @like_a_window_into_an_s3_bucket
files = ( 'VEG_NAME_TO_SOIL_TYPE_PIPE.txt')
file_format = ( format_name=PIPECOLSEP_ONEHEADROW );

create or replace table LU_SOIL_TYPE(
SOIL_TYPE_ID number,	
SOIL_TYPE varchar(15),
SOIL_DESCRIPTION varchar(75)
 );
 
 
 create or replace file format L8_CHALLENGE_FF
  type = CSV
  field_delimiter = '\t'
  skip_header = 1
  trim_space = TRUE;
  compression = none;
  
desc file format L8_CHALLENGE_FF;  
copy into LU_SOIL_TYPE
from @like_a_window_into_an_s3_bucket
files = ('LU_SOIL_TYPE.tsv')
file_format = (format_name = L8_CHALLENGE_FF)
FORCE = TRUE;

select * from LU_SOIL_TYPE;
--delete from LU_SOIL_TYPE;

create or replace table VEGETABLE_DETAILS_PLANT_HEIGHT  (
    plant_name varchar(25),
    UOM varchar(1),
    Low_End_of_Range number,
    High_End_of_Range number
);

show file formats;
desc file format COMMASEP_DBLQUOT_ONEHEADROW;

copy into VEGETABLE_DETAILS_PLANT_HEIGHT
from @like_a_window_into_an_s3_bucket
files = ('veg_plant_height.csv')
file_format = (format_name = COMMASEP_DBLQUOT_ONEHEADROW)
FORCE = TRUE;

select * from VEGETABLE_DETAILS_PLANT_HEIGHT;