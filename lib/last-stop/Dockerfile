# set target in docker-compose as either "dev" or "prod" for multi-stage build

FROM node:18.15.0-alpine3.17 as deps

WORKDIR /app
COPY . /app/

ENV PATH /app/node_modules/.bin:$PATH
ARG REACT_APP_API_ENDPOINT
RUN echo "REACT_APP_API_ENDPOINT=${REACT_APP_API_ENDPOINT}" > .env
RUN npm install

FROM deps as dev
# CMD npm run start
#install nodemon to provide hot-reloading functionality.
RUN npm install nodemon --save-dev
COPY . /app/

#use nodemon to run the react application using npm.
CMD ["npm", "start"]

EXPOSE 3000


FROM deps as build-prod
RUN npm run build

FROM nginx:stable-alpine3.17-slim as prod

WORKDIR /usr/share/nginx/html
COPY --from=build-prod ./app/build .

EXPOSE 80
ENTRYPOINT [ "nginx", "-g", "daemon off;" ]