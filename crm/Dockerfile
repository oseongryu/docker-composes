FROM tomcat:8.5-jdk8-openjdk

RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY script/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
