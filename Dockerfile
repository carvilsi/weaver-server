FROM node:6.11.3-alpine

RUN mkdir -p /usr/src/app

COPY ./lib /usr/src/app/lib
COPY ./img /usr/src/app/img
COPY ./views /usr/src/app/views
COPY ./node_modules /usr/src/app/node_modules
COPY ./package.json /usr/src/app/
COPY ./config /usr/src/app/config
COPY ./plugins /usr/src/app/plugins

RUN mkdir -p /usr/src/app/uploads
RUN mkdir -p /usr/src/app/logs
RUN mkdir -p /usr/src/app/loki

#RUN echo '#!/bin/bash' > /usr/health.sh
#RUN echo "a=\$(curl -Is http://localhost:9474/connection | head -n 1|cut -d\$' ' -f2);if [ \"\$a\" == \"200\" ]; then exit 0; else exit 1; fi" >> /usr/health.sh
#RUN chmod 777 /usr/health.sh
#HEALTHCHECK CMD /usr/health.sh

WORKDIR /usr/src/app
RUN npm install bcrypt@1.0.2
CMD node lib/index.js
