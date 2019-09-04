FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-stretch-slim AS base

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

#Angular build
FROM node as nodebuilder

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH


# install and cache app dependencies
COPY ClientApp/package.json /usr/src/app/package.json
RUN npm install
RUN npm install -g @angular/cli@1.7.0 --unsafe

# add app

COPY ClientApp/. /usr/src/app
#COPY ClientApp/node_modules/. /usr/src/app

RUN npm run build

#End Angular build

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
RUN mkdir -p /app/ClientApp/dist
COPY --from=nodebuilder /usr/src/app/dist/. /app/ClientApp/dist/
ENTRYPOINT ["dotnet", "ReactWithNotNetCore.dll"]