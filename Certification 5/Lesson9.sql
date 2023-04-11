
alter task AGS_GAME_AUDIENCE.RAW.CDC_LOAD_LOGS_ENHANCED suspend;  
/** For batch run this query
alter pipe AGS_GAME_AUDIENCE.RAW.GET_NEW_FILES set pipe_execution_paused = false;
**/

create schema  CURATED;

select 'hello';


select current_account();

select current_region();

