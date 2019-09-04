FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-stretch-slim AS base

WORKDIR /app
EXPOSE 80
EXPOSE 443

COPY ./ClientApp/package.json /app/package.json

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get update -yq && apt-get upgrade -yq && apt-get install -yq curl git nano
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && apt-get install -yq nodejs build-essential
RUN npm install -g npm
RUN npm install -g @angular/cli

FROM mcr.microsoft.com/dotnet/core/sdk:2.1-stretch AS build
WORKDIR /src
COPY ["ReactWithNotNetCore.csproj", ""]
RUN dotnet restore "./ReactWithNotNetCore.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "ReactWithNotNetCore.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "ReactWithNotNetCore.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "ReactWithNotNetCore.dll"]