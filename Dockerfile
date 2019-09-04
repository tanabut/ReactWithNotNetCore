FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-stretch-slim AS base

WORKDIR /app
EXPOSE 80
EXPOSE 443

COPY ./ClientApp/package.json /app/package.json

RUN curl -sL https://deb.nodesource.com/setup_10.x |  bash -
RUN apt-get install -y nodejs

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