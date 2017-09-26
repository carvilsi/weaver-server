FROM node:6.11.3-alpine
RUN mkdir -p /usr/src/app/uploads /usr/src/app/logs /usr/src/app/loki

WORKDIR /usr/src/app

COPY . /usr/src/app/

#RUN echo '#!/bin/bash' > /usr/health.sh
#RUN echo "a=\$(curl -Is http://localhost:9474/connection | head -n 1|cut -d\$' ' -f2);if [ \"\$a\" == \"200\" ]; then exit 0; else exit 1; fi" >> /usr/health.sh
#RUN chmod 777 /usr/health.sh
#HEALTHCHECK CMD /usr/health.sh

RUN apk --no-cache add --virtual native-deps \
  git g++ gcc libgcc libstdc++ linux-headers make python && \
  npm install coffee node-gyp -g &&\
  npm install --build-from-source=bcrypt && \
  npm cache clean --force &&\
  apk del native-deps &&\
  npm run prepublish && \
  npm prune --production &&\
  npm uninstall -g coffee node-gyp

CMD node lib/index.js
