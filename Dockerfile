FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1296032927779393627/WtGHM_sTkuwEQgEKqSbrZ6cp9lsvvS5QeygXwozXRIpbPZxwtbDnlCaSPw6a69P3XiX4
ENV JAVA_VERSION=11
ENV JAVA_HOME=/usr/lib/jvm/java-$JAVA_VERSION-openjdk-amd64

RUN apt-get update -qq && \
    apt-get install -y -qq ant curl openjdk-11-jdk && \
    mkdir -p /app/deps && \
    curl -L --output /app/deps/ivy-2.5.2.jar https://repo1.maven.org/maven2/org/apache/ivy/ivy/2.5.2/ivy-2.5.2.jar

WORKDIR /app

COPY . .

RUN ant -lib deps compile
RUN ant -lib deps dist
RUN ant -lib deps test

RUN ls -la /app

#RUN ls -la /app/bin
#RUN ls -la /app/dist
#RUN #cp /app/bin/Tetris.jar /app/Tetris.jar

RUN if [ $? -eq 0 ]; then \
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Tests passed successfully.\"}" $DISCORD_WEBHOOK_URL; \
    else \
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Tests failed. Check the logs.\"}" $DISCORD_WEBHOOK_URL; \
        cat test-reports/test.log | curl -F 'file=@-;filename=test.log' $DISCORD_WEBHOOK_URL; \
    fi

RUN curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Pipeline finished with status: $?\"}" $DISCORD_WEBHOOK_URL

CMD ["tail", "-f", "/dev/null"]
