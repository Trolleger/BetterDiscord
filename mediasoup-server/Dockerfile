FROM node:20-alpine

WORKDIR /app

RUN apk add \
    python3 py3-pip make g++ bash linux-headers musl-dev

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

CMD ["node", "server.js"]
