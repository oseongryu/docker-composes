-- 테이블 스페이스 생성
CREATE TABLESPACE TS_DB  datafile '/u01/app/oracle/oradata/XE/TS_DB.dbf' SIZE 100M AUTOEXTEND on next 100M;
-- 임시 테이블스페이스 생성
CREATE TEMPORARY TABLESPACE TS_DB_TEMP  TEMPFILE  '/u01/app/oracle/oradata/XE/TS_DB_TEMP.dbf' SIZE 100M AUTOEXTEND on next 10M;

create user emt identified by emt default tablespace users;
grant connect, resource to emt;
grant create any table to emt;
grant create any directory to emt;
grant drop any directory to emt;
grant sysdba to emt;

create directory save as '/app';
grant read, write on directory save to emt;
grant dba to emt with admin option;


-- 테이블스페이스 사용권한
-- GRANT UNLIMITED TABLESPACE TO emt;