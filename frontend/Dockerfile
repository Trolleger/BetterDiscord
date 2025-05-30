FROM node:20 as builder

WORKDIR /app

RUN apk add --no-cache yarn

# Copy package.json and yarn.lock first (to leverage cache)
COPY package.json yarn.lock ./

# Install dependencies before copying all source (faster rebuilds)
RUN yarn install

# Force right esbuild version
RUN yarn add -D esbuild@0.25.4

# Copy the rest of the source files
COPY . .

# Build the app
RUN yarn build

# Debug: list build folder
RUN ls -l /app/build

FROM nginx:latest

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
