FROM openjdk:11.0.13-jdk-oracle

RUN curl "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein" > /bin/lein
RUN chmod +x /bin/lein && lein version

WORKDIR /app

COPY project.clj .
RUN lein install

COPY src src
COPY test test
RUN lein uberjar

FROM openjdk:11.0.13-jre-slim-bullseye

WORKDIR /app

COPY --from=0 /app/target/uberjar/delete-message-bot-0.1.0-SNAPSHOT-standalone.jar app.jar

ENTRYPOINT [ "java", "-jar", "/app/app.jar" ]
