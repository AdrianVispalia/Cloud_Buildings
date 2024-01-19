FROM node:19-alpine3.15

WORKDIR /app

RUN apk update && apk upgrade
RUN apk add git

# COPY ./package*.json /app/

COPY package.json /app/
COPY yarn.lock /app/

# RUN yarn add @pinia/nuxt pinia

RUN yarn

# RUN npm install && npm cache clean --force


COPY . .

ENV PATH ./node_modules/.bin/:$PATH
