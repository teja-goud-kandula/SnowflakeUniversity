select * from AGS_GAME_AUDIENCE.RAW.LOGS where lower(user_login) like '%prajin%';

/*DATETIME_ISO8601 is in UTC format*/
select parse_ip('100.41.16.160','inet'):ipv4;
create schema ENHANCED;

--Look up Kishore and Prajina's Time Zone in the IPInfo share using his headset's IP Address with the PARSE_IP function.
select start_ip, end_ip, start_ip_int, end_ip_int, city, region, country, timezone
from IPINFO_GEOLOC.demo.location
where parse_ip('100.41.16.160', 'inet'):ipv4 --Kishore's Headset's IP Address
BETWEEN start_ip_int AND end_ip_int;


--Join the log and location tables to add time zone to each row using the PARSE_IP function.
select logs.*
       , loc.city
       , loc.region
       , loc.country
       , loc.timezone
from AGS_GAME_AUDIENCE.RAW.LOGS logs
join IPINFO_GEOLOC.demo.location loc
where parse_ip(logs.ip_address, 'inet'):ipv4 
BETWEEN start_ip_int AND end_ip_int;


--Use two functions supplied by IPShare to help with an efficient IP Lookup Process!
create table ags_game_audience.enhanced.logs_enhanced as( 
SELECT logs.ip_address
, logs.user_login as gamer_name
, logs.user_event as game_event_name
, logs.datetime_iso8601 as game_event_utc
, city
, region
, country
, timezone as gamer_ltz_name
, convert_timezone('UTC',timezone,logs.datetime_iso8601) as game_event_ltz
, dayname(game_event_ltz) as DOW_NAME
, TIME_OF_DAY_LU.TOD_NAME
from AGS_GAME_AUDIENCE.RAW.LOGS logs
JOIN IPINFO_GEOLOC.demo.location loc 
ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
JOIN AGS_GAME_AUDIENCE.RAW.TIME_OF_DAY_LU as TIME_OF_DAY_LU 
ON HOUR(convert_timezone('UTC',timezone,logs.datetime_iso8601)) = TIME_OF_DAY_LU.HOUR
AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address) 
BETWEEN start_ip_int AND end_ip_int
);


create table ags_game_audience.raw.time_of_day_lu
(  hour number
   ,tod_name varchar(25)
);

--insert statement to add all 24 rows to the table
insert into raw.time_of_day_lu
values
(6,'Early morning'),
(7,'Early morning'),
(8,'Early morning'),
(9,'Mid-morning'),
(10,'Mid-morning'),
(11,'Late morning'),
(12,'Late morning'),
(13,'Early afternoon'),
(14,'Early afternoon'),
(15,'Mid-afternoon'),
(16,'Mid-afternoon'),
(17,'Late afternoon'),
(18,'Late afternoon'),
(19,'Early evening'),
(20,'Early evening'),
(21,'Late evening'),
(22,'Late evening'),
(23,'Late evening'),
(0,'Late at night'),
(1,'Late at night'),
(2,'Late at night'),
(3,'Toward morning'),
(4,'Toward morning'),
(5,'Toward morning');

select tod_name, listagg(hour,',') 
from time_of_day_lu
group by tod_name
order by 2;