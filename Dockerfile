FROM node:0.12

RUN mkdir -p /usr/src/app

COPY ./lib /usr/src/app/lib
COPY ./node_modules /usr/src/app/node_modules
COPY ./package.json /usr/src/app/

EXPOSE 9487

WORKDIR /usr/src/app/lib
CMD node run.js