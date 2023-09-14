-- 테이블 스페이스 생성
CREATE TABLESPACE TS_DB  datafile '/u01/app/oracle/oradata/XE/TS_DB.dbf' SIZE 100M AUTOEXTEND on next 100M;
-- 임시 테이블스페이스 생성
CREATE TEMPORARY TABLESPACE TS_DB_TEMP  TEMPFILE  '/u01/app/oracle/oradata/XE/TS_DB_TEMP.dbf' SIZE 100M AUTOEXTEND on next 10M;

-- 계정생성
CREATE USER emt  IDENTIFIED BY  "emt"
-- DEFAULT TABLESPACE TS_DB
-- TEMPORARY TABLESPACE TS_DB_TEMP
-- QUOTA UNLIMITED ON TS_DB;

-- 접속 권한주기
GRANT RESOURCE, CONNECT to emt;
grant sysdba to emt;
-- grant read, write on directory save to emt;
GRANT CREATE ANY TABLE TO emt;
GRANT CREATE ANY directory TO emt;
grant drop any directory to emt;
-- GRANT DBA to emt;
GRANT DBA TO emt WITH ADMIN OPTION;


-- 테이블스페이스 사용권한
-- GRANT UNLIMITED TABLESPACE TO emt;