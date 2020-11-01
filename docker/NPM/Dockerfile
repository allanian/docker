FROM node:alpine AS builder

COPY ./ /tmp/build
WORKDIR /tmp/build
RUN npm set progress=false && npm i -g typescript --unsafe-perm && npm i
RUN npm run build:server

EXPOSE 3000
CMD [ "node", "dist/server/server.js" ]
