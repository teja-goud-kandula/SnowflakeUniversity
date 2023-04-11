use role sysadmin;
create database AGS_GAME_AUDIENCE;
drop schema public;
create schema RAW;


create or replace TABLE AGS_GAME_AUDIENCE.RAW.GAME_LOGS(
	RAW_LOG VARIANT
);

/*create stage*/
create stage uni_kishore
	url = 's3://uni-kishore';

/*checking if the stage is created correctly or not*/
list @uni_kishore/kickoff;

/*creating file format*/
CREATE OR REPLACE FILE FORMAT AGS_GAME_AUDIENCE.RAW.FF_JSON_LOGS
  TYPE = JSON
  strip_outer_array = true;

/*querying files from an external stage*/
select $1
from @uni_kishore/kickoff
(file_format => FF_JSON_LOGS);

/*copying and loading the data into a table*/
copy into ags_game_audience.raw.GAME_LOGS
from @uni_kishore/kickoff
file_format = (format_name = FF_JSON_LOGS);

create view AGS_GAME_AUDIENCE.RAW.LOGS as 
select 
    RAW_LOG:agent::text as agent,
    RAW_LOG:user_event::text as user_event,
    RAW_LOG:user_login::text as user_login,
    RAW_LOG:datetime_iso8601::timestamp_ntz as datetime_iso8601,
    RAW_LOG
from ags_game_audience.raw.GAME_LOGS ;

select * from AGS_GAME_AUDIENCE.RAW.LOGS;


/*checking data from the updated feed*/
/*querying files from an external stage*/
select $1
from @uni_kishore/updated_feed
(file_format => FF_JSON_LOGS);

/*copying and loading the data into a table*/
copy into ags_game_audience.raw.GAME_LOGS
from @uni_kishore/updated_feed
file_format = (format_name = FF_JSON_LOGS);

create or replace view AGS_GAME_AUDIENCE.RAW.LOGS as 
select 
    -- RAW_LOG:agent::text as agent,
    RAW_LOG:ip_address::text as ip_address,
    RAW_LOG:user_event::text as user_event,
    RAW_LOG:user_login::text as user_login,
    RAW_LOG:datetime_iso8601::timestamp_ntz as datetime_iso8601,
    RAW_LOG
from ags_game_audience.raw.GAME_LOGS where ip_address is not null;

select * from AGS_GAME_AUDIENCE.RAW.LOGS where lower(user_login) like '%prajin%';

/*DATETIME_ISO8601 is in UTC format*/
select parse_ip('100.41.16.160','inet'):ipv4;