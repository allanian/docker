FROM mcr.microsoft.com/dotnet/core/sdk:latest
WORKDIR app
ARG APP
ARG CI_PROJECT_ID
ARG CI_SERVER_URL
ARG CI_JOB_TOKEN
ARG PACKAGE_SOURCE=$CI_SERVER_URL/api/v4/projects/96/packages/nuget/index.json
COPY ./src ./src
COPY ./tests ./tests
WORKDIR /app/src
RUN mkdir packages
RUN dotnet restore ./$APP && dotnet build ./$APP -c Release --no-restore
# Проверяем наличие папки с тестами и если существует, то делаем dotnet restore, build и test для тестов проекта
RUN (test -d ../tests/$APP.Tests || echo "---- $APP.Tests does not exist ----") \
 && (dotnet restore ../tests/$APP.Tests || echo "---- $APP.Tests does not restored ----") \
 && (dotnet build ../tests/$APP.Tests -c Release --no-restore || echo "---- $APP.Tests does not builded ----") \
 && (dotnet test ../tests/$APP.Tests --no-build -c Release || echo "---- $APP.Tests failed ----")
RUN dotnet pack ./$APP -c Release --no-build --include-source -o ./packages/
RUN dotnet nuget add source $PACKAGE_SOURCE --name gitlab --username gitlab-ci-token --password $CI_JOB_TOKEN --store-password-in-clear-text
RUN dotnet nuget push "./packages/*.nupkg" --source gitlab
