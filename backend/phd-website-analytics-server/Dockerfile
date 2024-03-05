FROM gradle:8.5 as build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN gradle build --no-daemon

FROM openjdk:21-slim-bullseye

RUN mkdir /app
COPY --from=build /home/gradle/src/build/libs/phd-website-analytics-server-*.jar /app/phd-website-analytics-server.jar
ENTRYPOINT ["java", "-jar", "/app/phd-website-analytics-server.jar"]
