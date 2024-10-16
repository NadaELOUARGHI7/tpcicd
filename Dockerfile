FROM ubuntu:latest

ENV NONINTERACTIVE_FRONTEND=noninteractive
ENV DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1296208255651151952/1VEEXT2Z9dlUSXF-EnBBYErW_1ZuQn86hVW6N3myhCI0OLTuVYDmveqdRk3XAUlmrTo4
ENV JDK_HOME=/usr/lib/jvm/java-$JDK_VERSION-openjdk-amd64

RUN apt-get update -qq && \
    apt-get install -y -qq ant curl openjdk-17-jdk && \
    mkdir -p /project/dependencies && \
    curl -L --output /project/dependencies/ivy-2.5.2.jar https://repo1.maven.org/maven2/org/apache/ivy/ivy/2.5.2/ivy-2.5.2.jar

WORKDIR /project

COPY . .

RUN ant -lib dependencies compile

RUN ant -lib dependencies test


RUN if [ $? -eq 0 ]; then \
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Tests passed successfully.\"}" $DISCORD_WEBHOOK_URL; \
    else \
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Tests failed. Check the logs.\"}" $DISCORD_WEBHOOK_URL; \
        cat test-reports/test.log | curl -F 'file=@-;filename=test.log' $DISCORD_WEBHOOK_URL; \
    fi

RUN curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"Pipeline finished with status: $?\"}" $DISCORD_WEBHOOK_URL

CMD ["tail", "-f", "/dev/null"]
