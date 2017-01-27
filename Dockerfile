FROM node:6.9.2

RUN mkdir -p /usr/src/app

COPY ./lib /usr/src/app/lib
COPY ./node_modules /usr/src/app/node_modules
COPY ./package.json /usr/src/app/
COPY ./config /usr/src/app/config

EXPOSE 9487

WORKDIR /usr/src/app
CMD node lib/index.js
