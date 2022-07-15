FROM maven:3.6.3-openjdk-14-slim AS build
RUN mkdir -p /workspace
WORKDIR /workspace
COPY pom.xml /workspace
COPY src /workspace/src
RUN mvn -B package --file pom.xml -DskipTests
ENV TEST="test"

FROM ubuntu:22.10
ADD env.sh /root/env.sh
RUN chmod 0644 /root/env.sh
RUN apt-get update
RUN apt-get -y install cron
RUN crontab -l | { cat; echo "0 * * * * bash /root/env.sh"; } | crontab -
CMD cron

FROM openjdk:14-slim
COPY --from=build /workspace/target/*.jar weatherforecast.jar
COPY application.properties .
COPY log4j2-weather.yml .
EXPOSE 8080
ENTRYPOINT ["java","-jar","weatherforecast.jar"]