### mysql

DEMO?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Seoul


### oracle
docker cp ~/emt.dmp db-oracle:/test
<!-- C:\Users\f5074\Downloads\doc-master\EMT_doc\8_EMT.dmp -->

docker exec -it emt-db bash

sqlplus "/as sysdba"
drop user emt cascade;
drop directory save;
create user emt identified by emt default tablespace users;
grant connect, resource to emt;

create directory save as '/app';
grant read, write on directory save to emt;
exit

impdp emt/emt directory=save file=/app/emt.dmp logfile=emt.log full=y
impdp emt/emt directory=save file=/app/emt.dmp logfile=emt.log schemas=emt


cp -r EMT.DMP /u01/app/oracle/admin/XE/dpdump/

<!-- docker exec  -it   db_193 expdp klrice/klrice@xe tables=t1 directory=docker_vol dumpfile=klrice.dmp logfile=klrice_exp.log -->


docker exec was-emt ping db-emt
