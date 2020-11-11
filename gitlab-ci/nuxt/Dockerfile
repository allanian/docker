FROM node:11.13.0-alpine
WORKDIR /opt/app
RUN apk add g++ make python
COPY . .
RUN npm install
RUN npm run build

#RUN npm install sass-loader node-sass
#--save-dev
#RUN npm install --save-dev node-sass

EXPOSE 3000

ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

CMD [ "npm", "start" ]
