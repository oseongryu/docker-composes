#!/bin/bash
nohup /app/java/jdk-8u212-ojdkbuild-linux-x64/bin/java -jar -Dserver.port=10100 /app/script/java-0.0.1-SNAPSHOT.jar 1>/dev/null 2>&1 &