#!/bin/bash
set -e

cd /app/source
mvn package -DskipTests

rm -rf /usr/local/tomcat/webapps/ROOT
cp -r target/hyp-1.0.0 /usr/local/tomcat/webapps/ROOT

exec /usr/local/tomcat/bin/catalina.sh run
