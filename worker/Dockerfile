# because of dotnet, we always build on amd64, and target platforms in cli
# dotnet doesn't support QEMU for building or running. 
# (errors common in arm/v7 32bit) https://github.com/dotnet/dotnet-docker/issues/1537
# https://hub.docker.com/_/microsoft-dotnet
# hadolint ignore=DL3029
# to build for a different platform than your host, use --platform=<platform>
# for example, if you were on Intel (amd64) and wanted to build for ARM, you would use:
# docker buildx build --platform "linux/arm64/v8" .

# build compiles the program for the builder's local platform
FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:7.0 AS build
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

WORKDIR /source
COPY *.csproj .
RUN dotnet restore -a $TARGETARCH

COPY . .
RUN dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore
docker compose build result
docker compose up
# app image
FROM mcr.microsoft.com/dotnet/runtime:7.0
WORKDIR /app

# 1. Create a non-root system user and group
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 2. Copy the built app files and assign ownership to appuser
COPY --chown=appuser:appuser --from=build /app .

# 3. Switch from root to the non-root user
USER appuser

ENTRYPOINT ["dotnet", "Worker.dll"]

