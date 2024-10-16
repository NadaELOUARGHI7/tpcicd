FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1296032927779393627WtGHM_sTkuwEQgEKqSbrZ6cp9lsvvS5QeygXwozXRIpbPZxwtbDnlCaSPw6a69P3XiX4
ENV JAVA_VERSION=17
ENV JAVA_HOME=/usr/lib/jvm/java-$JAVA_VERSION-openjdk-amd64

RUN apt-get update -qq && \
    apt-get install -y -qq ant curl openjdk-17-jdk && \
    mkdir -p /project/dependencies && \
    curl -L --output /project/dependencies/ivy-2.5.2.jar https://repo1.maven.org/maven2/org/apache/ivy/ivy/2.5.2 ivy-2.5.2.jar

WORKDIR /app

COPY . .

RUN ant -lib dependencies compile
RUN ant -lib dependencies dist
RUN ant -lib dependencies test

RUN ls -la /app
