FROM node:8-alpine
RUN mkdir /app
WORKDIR /app
COPY ClientApp/package.json /app
RUN apk add --no-cache ffmpeg opus pixman cairo pango giflib ca-certificates \
    && apk add --no-cache --virtual .build-deps python g++ make gcc .build-deps curl git pixman-dev cairo-dev pangomm-dev libjpeg-turbo-dev giflib-dev \
    && npm install \
    && apk del .build-deps
COPY . /app
CMD ["npm", "start"]

FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-stretch-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

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