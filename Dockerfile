FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build-env

WORKDIR /app

COPY src/ ./
RUN dotnet publish -c Release -o out


# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim


RUN apt-get update
RUN apt-get install -y libgdiplus libc6-dev
RUN apt-get install -y libicu-dev libharfbuzz0b libfontconfig1 libfreetype6
RUN apt-get install -y wget

RUN apt install -y default-jre
RUN wget https://github.com/liquibase/liquibase/releases/download/v4.5.0/liquibase-4.5.0.tar.gz
RUN wget https://jdbc.postgresql.org/download/postgresql-42.3.0.jar


RUN mkdir liquibase

RUN tar -xvf liquibase-4.5.0.tar.gz -C /liquibase
RUN mv postgresql-42.3.0.jar /liquibase/lib/
ENV PATH="/liquibase:${PATH}"




#ENV MICRO_REGISTRY "kubernetes"
#ENV MICRO_SERVER_ADDRESS "0.0.0.0:8080"
#ENV MICRO_BROKER_ADDRESS "0.0.0.0:8081"

#RUN apt update && apt install openssl musl-dev ca-certificates tcpdump
WORKDIR /app
COPY --from=build-env /app/out ./

COPY migrations /app

COPY assets ./

RUN chmod 755 /app/docker-entrypoint.sh
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["dotnet", "AddInn.ULM.Api.dll"]
