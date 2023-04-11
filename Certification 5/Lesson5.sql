use database ags_game_audience;
use schema raw;
create task load_logs_enhanced
	warehouse = 'COMPUTE_WH'
	schedule = '5 minute'
as 
	select 'hello';

show tasks;    
-- drop task load_logs_enhanced;


--You have to run this grant or you won't be able to test your tasks while in SYSADMIN role
--this is true even if SYSADMIN owns the task!!
-- use role accountadmin;
grant execute task on account to role SYSADMIN;
use role sysadmin;

--Now you should be able to run the task, even if your role is set to SYSADMIN
execute task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

--the SHOW command might come in handy to look at the task 
show tasks in account;

--you can also look at any task more in depth using DESCRIBE
describe task AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

