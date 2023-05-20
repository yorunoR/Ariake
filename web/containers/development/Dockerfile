FROM node:18.16-alpine

WORKDIR /web

COPY package.json /web/package.json

RUN apk --no-cache --virtual build-dependencies add \
    && yarn install \
    && apk del build-dependencies
