#!/bin/bash
nohup /app/java/zulu8.78.0.19-ca-jdk8.0.412-linux_x64/bin/java -jar -Dserver.port=9551 /app/script/fo-0.0.1-SNAPSHOT.jar 1>/dev/null 2>&1 &
echo "start_was"