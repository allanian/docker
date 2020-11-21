FROM openjdk:8u232-jdk-slim
# arg with microservice name
ARG APP
# entrypoint from microservice
ADD ./$APP/docker/run.sh run.sh
# configs service for microservice config-service
COPY ./config-service/parking-configs /configs-dir/
# copy jar file downloaded from package registry
ADD ./*.jar app.jar
# netcat for monitor db
RUN apt-get update && apt-get install -y netcat && rm -rf /var/lib/apt/lists/*
RUN mkdir /logs && chmod 755 /logs && chmod +x run.sh && ls -la
CMD /run.sh