FROM gradle:5.1.1-jdk8-alpine
WORKDIR /app
COPY --from=0 /app/myProject /app

USER root                # This changes default user to root
RUN chown -R gradle /app # This changes ownership of folder
USER gradle              # This changes the user back to the default user "gradle"

RUN ./gradlew build --stacktrace

# base image
FROM gradle:5.1.1-jdk8-alpine

# set working directory
RUN mkdir /emp_app
WORKDIR /emp_app

# install and cache app dependencies
#COPY --from=0 /app/myProject /emp_app
COPY . /emp_app/

USER root                    # This changes default user to root
RUN chown -R gradle /emp_app # This changes ownership of folder
USER gradle              # This changes the user back to the default user "gradle"

# start app
RUN ./gradlew build --stacktrace
