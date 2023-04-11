create stage UNI_KISHORE_PIPELINE 
URL = 's3://uni-kishore-pipeline';

list @UNI_KISHORE_PIPELINE;

select $1, $2, $3, $4
from @UNI_KISHORE_PIPELINE/logs_101_110_0_0_0.json;

create table RAW.PIPELINE_LOGS (
    RAW_LOG VARIANT 
);

/*copying and loading the data into a table*/
copy into ags_game_audience.raw.PIPELINE_LOGS
from @UNI_KISHORE_PIPELINE
file_format = (format_name = FF_JSON_LOGS);

select * from ags_game_audience.raw.PIPELINE_LOGS;

create or replace view AGS_GAME_AUDIENCE.RAW.PL_LOGS(
	IP_ADDRESS,
	USER_EVENT,
	USER_LOGIN,
	DATETIME_ISO8601,
	RAW_LOG
) as 
select 
    -- RAW_LOG:agent::text as agent,
    RAW_LOG:ip_address::text as ip_address,
    RAW_LOG:user_event::text as user_event,
    RAW_LOG:user_login::text as user_login,
    RAW_LOG:datetime_iso8601::timestamp_ntz as datetime_iso8601,
    RAW_LOG
from ags_game_audience.raw.PIPELINE_LOGS where ip_address is not null;

select * from AGS_GAME_AUDIENCE.RAW.PL_LOGS;

select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

-- Updating the LOAD_LOGS_ENHANCED task 
create or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED
	warehouse=COMPUTE_WH
	schedule='5 minute'
	as MERGE INTO AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED e
USING (
    SELECT logs.ip_address 
    , logs.user_login as GAMER_NAME
    , logs.user_event as GAME_EVENT_NAME
    , logs.datetime_iso8601 as GAME_EVENT_UTC
    , city
    , region
    , country
    , timezone as GAMER_LTZ_NAME
    , CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) as game_event_ltz
    , DAYNAME(game_event_ltz) as DOW_NAME
    , TOD_NAME
    from ags_game_audience.raw.PL_LOGS logs
    JOIN ipinfo_geoloc.demo.location loc 
    ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
    BETWEEN start_ip_int AND end_ip_int
    JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
    ON HOUR(game_event_ltz) = tod.hour
) r
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
WHEN NOT MATCHED THEN 
INSERT ( IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME ) 
VALUES ( IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME,             GAME_EVENT_LTZ, DOW_NAME, TOD_NAME );


create or replace task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
	warehouse=COMPUTE_WH
	schedule='5 minute'
	as copy into ags_game_audience.raw.PIPELINE_LOGS
from @UNI_KISHORE_PIPELINE
file_format = (format_name = FF_JSON_LOGS);

show tasks;

execute task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES;
-- stage
list @UNI_KISHORE_PIPELINE; -- 34 files -- 38 files 
-- view 
select * from AGS_GAME_AUDIENCE.RAW.PL_LOGS; -- 320 -- 380
-- table 
select * from AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED; -- 300 
-- 46 files => 460 => 358
-- truncate table AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED;

alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES resume;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED resume;


--Keep this code handy for shutting down the tasks each day
alter task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES suspend;
alter task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED suspend;

-- 🥋 Grant Serverless Task Management to SYSADMIN

use role accountadmin;
grant EXECUTE MANAGED TASK on account to SYSADMIN;

--switch back to sysadmin
use role sysadmin;

/*Building dependency between the tasks and using serverless compute to run the tasks*/
create or replace task AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
	USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
	schedule='5 Minutes'
	as copy into ags_game_audience.raw.PIPELINE_LOGS
from @ags_game_audience.raw.UNI_KISHORE_PIPELINE
file_format = (format_name = FF_JSON_LOGS);


create or replace task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED
	USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
	after AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES
	as MERGE INTO AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED e
USING (
    SELECT logs.ip_address 
    , logs.user_login as GAMER_NAME
    , logs.user_event as GAME_EVENT_NAME
    , logs.datetime_iso8601 as GAME_EVENT_UTC
    , city
    , region
    , country
    , timezone as GAMER_LTZ_NAME
    , CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) as game_event_ltz
    , DAYNAME(game_event_ltz) as DOW_NAME
    , TOD_NAME
    from ags_game_audience.raw.PL_LOGS logs
    JOIN ipinfo_geoloc.demo.location loc 
    ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
    BETWEEN start_ip_int AND end_ip_int
    JOIN ags_game_audience.raw.TIME_OF_DAY_LU tod
    ON HOUR(game_event_ltz) = tod.hour
) r
ON r.GAMER_NAME = e.GAMER_NAME
AND r.GAME_EVENT_UTC = e.GAME_EVENT_UTC
AND r.GAME_EVENT_NAME = e.GAME_EVENT_NAME
WHEN NOT MATCHED THEN 
INSERT ( IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME, GAME_EVENT_LTZ, DOW_NAME, TOD_NAME ) 
VALUES ( IP_ADDRESS, GAMER_NAME, GAME_EVENT_NAME, GAME_EVENT_UTC, CITY, REGION, COUNTRY, GAMER_LTZ_NAME,             GAME_EVENT_LTZ, DOW_NAME, TOD_NAME );


show tasks;

-- select * --from TASK_HISTORY() ;( TASK_NAME => 'GET_NEW_FILES' );
  select *
  from table(information_schema.task_history())
  order by scheduled_time desc
  limit 10
  ;

  select current_timestamp();
  
  ;
  -- from table(information_schema.task_history(TASK_NAME => 'GET_NEW_FILES'));

select current_timestamp();  